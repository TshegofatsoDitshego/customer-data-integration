# Setup Guide - Customer 360 Data Integration Platform

This guide walks you through setting up the entire project from scratch.

## Prerequisites

- Azure subscription (free tier works fine)
- SQL Server Management Studio or Azure Data Studio
- Python 3.8+ (for sample data generation)
- Git installed locally
- Basic knowledge of Azure Portal

**Estimated setup time:** 2-3 hours

---

## Step 1: Set Up Azure Resources

### 1.1 Create Resource Group
```bash
# Using Azure CLI (or do this in Portal)
az group create \
  --name rg-customer360-dev \
  --location southafricanorth
```

### 1.2 Create Storage Account
```bash
az storage account create \
  --name stcustomer360dev \
  --resource-group rg-customer360-dev \
  --location southafricanorth \
  --sku Standard_LRS
```

**In the Portal:**
1. Create container called `raw-data`
2. Create container called `processed-data`
3. Upload your sample CSV files to `raw-data`

### 1.3 Create Azure SQL Database
```bash
az sql server create \
  --name sql-customer360-dev \
  --resource-group rg-customer360-dev \
  --location southafricanorth \
  --admin-user sqladmin \
  --admin-password YourStr0ngP@ssword!

az sql db create \
  --resource-group rg-customer360-dev \
  --server sql-customer360-dev \
  --name CustomerDB \
  --service-objective S0
```

**Important:** Add your IP to firewall rules!

### 1.4 Create Azure Data Factory
```bash
az datafactory create \
  --resource-group rg-customer360-dev \
  --factory-name adf-customer360-dev \
  --location southafricanorth
```

---

## Step 2: Set Up Local Development

### 2.1 Clone Repository
```bash
git clone https://github.com/yourusername/customer-data-integration.git
cd customer-data-integration
```

### 2.2 Install Python Dependencies
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**requirements.txt:**
```
faker==20.1.0
requests==2.31.0
pandas==2.1.4
openpyxl==3.1.2
```

### 2.3 Generate Sample Data
```bash
cd scripts
python generate_sample_data.py
```

---

## Step 3: Set Up Database

### 3.1 Connect to Azure SQL

Using Azure Data Studio or SSMS:
- Server: `sql-customer360-dev.database.windows.net`
- Database: `CustomerDB`
- Authentication: SQL Login
- Username: `sqladmin`
- Password: (your password)

### 3.2 Run SQL Scripts

Execute in this order:
1. `sql/01_create_tables.sql` - Creates schema
2. `sql/02_stored_procedures.sql` - Creates stored procedures
3. `sql/03_data_quality_checks.sql` - Creates quality checks
4. Verify with `SELECT * FROM sys.tables`

---

## Step 4: Configure Azure Data Factory

### 4.1 Create Linked Services

**Blob Storage Linked Service:**
1. Go to ADF Author tab → Manage → Linked Services
2. Click "+ New"
3. Select "Azure Blob Storage"
4. Name: `LS_BlobStorage_Source`
5. Authentication: Account Key
6. Connect to your storage account

**Azure SQL Linked Service:**
1. Click "+ New"
2. Select "Azure SQL Database"
3. Name: `LS_AzureSQL_Target`
4. Server name: `sql-customer360-dev.database.windows.net`
5. Database: `CustomerDB`
6. Authentication: SQL Authentication
7. Test connection

### 4.2 Create Datasets

**CSV Dataset:**
1. Author tab → Datasets → "+ New"
2. Select "Azure Blob Storage" → "DelimitedText"
3. Name: `DS_CSV_Customers`
4. Linked service: `LS_BlobStorage_Source`
5. File path: `raw-data/customers.csv`
6. First row as header: Yes

**SQL Dataset:**
1. "+ New" → "Azure SQL Database"
2. Name: `DS_SQL_Customers`
3. Linked service: `LS_AzureSQL_Target`
4. Table: `dbo.Customers`

### 4.3 Import Pipelines

*(We'll create these in the next files)*

---

## Step 5: Test the Pipeline

### 5.1 Manual Trigger

1. Go to your pipeline `PL_Ingest_All_Sources`
2. Click "Debug" or "Add trigger" → "Trigger now"
3. Monitor in the "Monitor" tab

### 5.2 Verify Data
```sql
-- Check customer count
SELECT COUNT(*) FROM dbo.Customers;

-- View sample records
SELECT TOP 10 * FROM dbo.Customers
ORDER BY LastUpdated DESC;

-- Check data quality log
SELECT * FROM dbo.DataQualityLog
ORDER BY CheckDate DESC;

-- Check pipeline log
SELECT * FROM dbo.PipelineLog
ORDER BY StartTime DESC;
```

---

## Step 6: Set Up Microsoft Purview (Optional)

1. Create Purview account in Azure Portal
2. Register Azure SQL Database as data source
3. Run scan to catalog tables
4. View lineage in Purview Studio

**Note:** Purview is optional for demo but impressive in interviews!

---

## Step 7: Set Up CI/CD with Azure DevOps

### 7.1 Create Azure DevOps Project

1. Go to dev.azure.com
2. Create new project: "Customer360Pipeline"
3. Initialize Git repo

### 7.2 Connect ADF to DevOps

1. In ADF, go to Manage → Git configuration
2. Connect to Azure DevOps
3. Select your project and repo
4. Branch: `main`
5. Publish branch: `adf_publish`

### 7.3 Create Release Pipeline

*(Details in azure-pipelines/ci-cd-pipeline.yml)*

---

## Troubleshooting

### Common Issues

**Issue:** Can't connect to Azure SQL  
**Solution:** Check firewall rules, add your IP

**Issue:** ADF pipeline fails with "Forbidden"  
**Solution:** Check managed identity permissions on Storage Account

**Issue:** Data not appearing in SQL  
**Solution:** Check dataset schema matches table schema

**Issue:** Duplicate key errors  
**Solution:** Check UNIQUE constraint on email, implement MERGE logic

---

## Next Steps

Once basic pipeline works:
1. Add more data sources (Excel, API)
2. Implement incremental loads
3. Add Power BI dashboard
4. Set up automated triggers (daily at 2 AM)
5. Add alerting for failures

---

## Cost Management

**Free tier limits:**
- Azure SQL: 32GB free (S0 tier)
- Storage: 5GB free
- ADF: 1000 activities free/month

**Estimated monthly cost:** $10-30 depending on usage

To minimize costs:
- Pause SQL DB when not testing
- Delete resource group when done: `az group delete --name rg-customer360-dev`
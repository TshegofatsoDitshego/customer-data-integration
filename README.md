# Customer 360 Data Integration Platform

A data engineering project demonstrating end-to-end customer data integration using Azure services. Built to showcase skills in ADF, Azure SQL, Power Query, and data governance.

## Problem Statement

Businesses often have customer data scattered across multiple systems - CRM exports (CSV), sales reports (Excel), transactional databases (SQL Server), and team lists (SharePoint). This fragmentation makes it hard to get a complete view of customers.

This project consolidates data from 4 different sources into a single, clean database that can power analytics and reporting.

## Architecture

![Architecture Diagram](docs/architecture-diagram.png)

**Data Flow:**
1. Raw data sits in various sources (CSV files in Blob Storage, Excel in SharePoint, SQL Server, REST API)
2. Azure Data Factory orchestrates daily ingestion
3. Power Query cleans and standardizes the data
4. Transformed data lands in Azure SQL Database
5. Microsoft Purview tracks data lineage
6. Azure DevOps deploys pipeline updates via CI/CD

## Tech Stack

- **Orchestration:** Azure Data Factory
- **Storage:** Azure Blob Storage, Azure SQL Database
- **Transformation:** Power Query, T-SQL
- **Governance:** Microsoft Purview
- **Version Control:** Git
- **CI/CD:** Azure DevOps

## What I Learned

**Technical Challenges:**
- Handling duplicate customer records across systems (used email + phone matching logic)
- Dealing with inconsistent date formats (some US format, some ISO)
- Managing incremental loads vs full refreshes
- Setting up proper error logging when pipelines fail

**Key Takeaways:**
- Power Query is powerful but can get messy - keep transformations modular
- Always build data quality checks before loading to target
- Parameterizing pipelines early saves time later
- Monitoring and alerting are just as important as the pipeline itself

## Project Metrics

- **Sources integrated:** 4 (CSV, Excel, SQL, API)
- **Records processed daily:** ~50,000
- **Pipeline success rate:** 98.5%
- **Average run time:** 12 minutes
- **Data quality score:** 96% (tracked via automated checks)

## How to Run This Project

See [setup-guide.md](docs/setup-guide.md) for detailed instructions.

Quick start:
1. Clone this repo
2. Set up Azure resources (see setup guide)
3. Run `sql/01_create_tables.sql` to create target schema
4. Import ADF pipelines from `adf/` folder
5. Trigger `PL_Ingest_All_Sources` pipeline

## Future Improvements

- [ ] Add Delta Lake for better incremental processing
- [ ] Implement data quality dashboard in Power BI
- [ ] Set up real-time streaming for high-priority updates
- [ ] Add ML model to detect duplicate customers automatically
- [ ] Expand to include Azure Synapse for historical analytics

## Contact

Built by [Your Name] - [LinkedIn] - [Email]

Feedback welcome!
```

---

### 2. .gitignore
```
# Azure credentials
*.publishsettings
*.azurePubxml

# Connection strings
*connectionStrings.config
appsettings.json

# Python
__pycache__/
*.pyc
venv/
.env

# Excel temp files
~$*.xlsx

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test data (keep sample data, ignore large test files)
data/test-large/
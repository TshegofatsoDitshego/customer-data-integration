-- Target database schema for Customer 360 view

-- Main customer table (source of truth)
CREATE TABLE dbo.Customers (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(50),
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(50),
    Country VARCHAR(100),
    SignupDate DATE,
    FirstOrderDate DATE,
    TotalOrders INT DEFAULT 0,
    TotalSpent DECIMAL(12,2) DEFAULT 0,
    CustomerStatus VARCHAR(50),
    LastUpdated DATETIME2 DEFAULT GETDATE(),
    SourceSystem VARCHAR(100),
    CONSTRAINT UQ_Email UNIQUE(Email)
);

-- Customer transactions (aggregated from multiple sources)
CREATE TABLE dbo.CustomerTransactions (
    TransactionKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerKey INT FOREIGN KEY REFERENCES dbo.Customers(CustomerKey),
    TransactionID VARCHAR(100),
    TransactionDate DATE,
    Amount DECIMAL(10,2),
    ProductCategory VARCHAR(100),
    Status VARCHAR(50),
    SourceSystem VARCHAR(100),
    LoadedDate DATETIME2 DEFAULT GETDATE()
);

-- Data quality log table
CREATE TABLE dbo.DataQualityLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    CheckDate DATETIME2 DEFAULT GETDATE(),
    TableName VARCHAR(100),
    CheckName VARCHAR(200),
    RecordsFailed INT,
    Severity VARCHAR(20),
    Details NVARCHAR(MAX)
);

-- Pipeline execution log
CREATE TABLE dbo.PipelineLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    PipelineName VARCHAR(200),
    RunID VARCHAR(100),
    StartTime DATETIME2,
    EndTime DATETIME2,
    Status VARCHAR(50),
    RecordsProcessed INT,
    ErrorMessage NVARCHAR(MAX)
);

-- Create indexes for performance
CREATE INDEX IX_Customers_Email ON dbo.Customers(Email);
CREATE INDEX IX_Customers_Status ON dbo.Customers(CustomerStatus);
CREATE INDEX IX_Transactions_CustomerKey ON dbo.CustomerTransactions(CustomerKey);
CREATE INDEX IX_Transactions_Date ON dbo.CustomerTransactions(TransactionDate);
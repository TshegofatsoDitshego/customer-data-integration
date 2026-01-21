-- Stored procedure to merge customer data (handles updates and inserts)
CREATE OR ALTER PROCEDURE dbo.usp_MergeCustomerData
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create staging table for incoming data
    IF OBJECT_ID('tempdb..#StagingCustomers') IS NOT NULL
        DROP TABLE #StagingCustomers;
    
    CREATE TABLE #StagingCustomers (
        CustomerID VARCHAR(50),
        FirstName VARCHAR(100),
        LastName VARCHAR(100),
        Email VARCHAR(255),
        Phone VARCHAR(50),
        Country VARCHAR(100),
        SignupDate DATE,
        SourceSystem VARCHAR(100)
    );
    
    -- This would normally be populated by ADF
    -- For testing, you can manually insert data here
    
    MERGE dbo.Customers AS target
    USING #StagingCustomers AS source
    ON target.Email = source.Email
    
    -- Update existing customers
    WHEN MATCHED THEN
        UPDATE SET
            target.FirstName = COALESCE(source.FirstName, target.FirstName),
            target.LastName = COALESCE(source.LastName, target.LastName),
            target.Phone = COALESCE(source.Phone, target.Phone),
            target.Country = COALESCE(source.Country, target.Country),
            target.LastUpdated = GETDATE()
    
    -- Insert new customers
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CustomerID, FirstName, LastName, Email, Phone, Country, SignupDate, SourceSystem, CustomerStatus)
        VALUES (source.CustomerID, source.FirstName, source.LastName, source.Email, 
                source.Phone, source.Country, source.SignupDate, source.SourceSystem, 'Active');
    
    -- Log the operation
    INSERT INTO dbo.PipelineLog (PipelineName, RunID, StartTime, EndTime, Status, RecordsProcessed)
    VALUES ('usp_MergeCustomerData', NEWID(), GETDATE(), GETDATE(), 'Success', @@ROWCOUNT);
    
END;
GO

-- Stored procedure to update customer metrics
CREATE OR ALTER PROCEDURE dbo.usp_UpdateCustomerMetrics
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE c
    SET 
        c.TotalOrders = t.OrderCount,
        c.TotalSpent = t.TotalAmount,
        c.FirstOrderDate = t.FirstOrder,
        c.CustomerStatus = CASE 
            WHEN t.FirstOrder >= DATEADD(MONTH, -3, GETDATE()) THEN 'Active'
            WHEN t.FirstOrder >= DATEADD(MONTH, -12, GETDATE()) THEN 'Inactive'
            ELSE 'Dormant'
        END,
        c.LastUpdated = GETDATE()
    FROM dbo.Customers c
    INNER JOIN (
        SELECT 
            CustomerKey,
            COUNT(*) as OrderCount,
            SUM(Amount) as TotalAmount,
            MIN(TransactionDate) as FirstOrder
        FROM dbo.CustomerTransactions
        GROUP BY CustomerKey
    ) t ON c.CustomerKey = t.CustomerKey;
    
END;
GO
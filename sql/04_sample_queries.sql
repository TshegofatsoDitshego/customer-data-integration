-- Useful queries for analyzing the customer data

-- Query 1: Customer lifetime value by country
SELECT 
    Country,
    COUNT(*) as CustomerCount,
    AVG(TotalSpent) as AvgLifetimeValue,
    SUM(TotalSpent) as TotalRevenue
FROM dbo.Customers
WHERE CustomerStatus IN ('Active', 'Inactive')
GROUP BY Country
ORDER BY TotalRevenue DESC;

-- Query 2: Customer cohort analysis (by signup month)
SELECT 
    FORMAT(SignupDate, 'yyyy-MM') as CohortMonth,
    COUNT(*) as NewCustomers,
    SUM(CASE WHEN CustomerStatus = 'Active' THEN 1 ELSE 0 END) as StillActive,
    AVG(TotalSpent) as AvgSpend
FROM dbo.Customers
GROUP BY FORMAT(SignupDate, 'yyyy-MM')
ORDER BY CohortMonth DESC;

-- Query 3: Top customers by spend
SELECT TOP 20
    CustomerID,
    FirstName + ' ' + LastName as CustomerName,
    Email,
    TotalOrders,
    TotalSpent,
    CustomerStatus,
    FirstOrderDate
FROM dbo.Customers
ORDER BY TotalSpent DESC;

-- Query 4: Transaction trends by month
SELECT 
    FORMAT(TransactionDate, 'yyyy-MM') as TransactionMonth,
    COUNT(*) as TransactionCount,
    SUM(Amount) as MonthlyRevenue,
    AVG(Amount) as AvgTransactionValue
FROM dbo.CustomerTransactions
WHERE Status = 'Completed'
GROUP BY FORMAT(TransactionDate, 'yyyy-MM')
ORDER BY TransactionMonth DESC;

-- Query 5: Data quality summary
SELECT 
    TableName,
    CheckName,
    MAX(RecordsFailed) as MaxFailures,
    AVG(CAST(RecordsFailed as FLOAT)) as AvgFailures,
    Severity
FROM dbo.DataQualityLog
WHERE CheckDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY TableName, CheckName, Severity
ORDER BY MaxFailures DESC;
-- Data quality validation queries

-- Check 1: Find customers with missing critical fields
INSERT INTO dbo.DataQualityLog (TableName, CheckName, RecordsFailed, Severity, Details)
SELECT 
    'Customers' as TableName,
    'Missing Email' as CheckName,
    COUNT(*) as RecordsFailed,
    'High' as Severity,
    'Customer records without email addresses' as Details
FROM dbo.Customers
WHERE Email IS NULL OR Email = '';

-- Check 2: Find duplicate emails
INSERT INTO dbo.DataQualityLog (TableName, CheckName, RecordsFailed, Severity, Details)
SELECT 
    'Customers' as TableName,
    'Duplicate Emails' as CheckName,
    COUNT(*) - COUNT(DISTINCT Email) as RecordsFailed,
    'High' as Severity,
    'Duplicate customer email addresses found' as Details
FROM dbo.Customers
HAVING COUNT(*) > COUNT(DISTINCT Email);

-- Check 3: Invalid phone formats
INSERT INTO dbo.DataQualityLog (TableName, CheckName, RecordsFailed, Severity, Details)
SELECT 
    'Customers' as TableName,
    'Invalid Phone Format' as CheckName,
    COUNT(*) as RecordsFailed,
    'Medium' as Severity,
    'Phone numbers not matching expected format' as Details
FROM dbo.Customers
WHERE Phone IS NOT NULL 
  AND Phone NOT LIKE '+27%'
  AND Phone NOT LIKE '0%';

-- Check 4: Future signup dates
INSERT INTO dbo.DataQualityLog (TableName, CheckName, RecordsFailed, Severity, Details)
SELECT 
    'Customers' as TableName,
    'Future Signup Date' as CheckName,
    COUNT(*) as RecordsFailed,
    'High' as Severity,
    'Signup dates in the future' as Details
FROM dbo.Customers
WHERE SignupDate > GETDATE();

-- Check 5: Negative transaction amounts
INSERT INTO dbo.DataQualityLog (TableName, CheckName, RecordsFailed, Severity, Details)
SELECT 
    'CustomerTransactions' as TableName,
    'Negative Amounts' as CheckName,
    COUNT(*) as RecordsFailed,
    'Medium' as Severity,
    'Transactions with negative amounts (excluding refunds)' as Details
FROM dbo.CustomerTransactions
WHERE Amount < 0 AND Status != 'Refunded';

-- View latest data quality results
SELECT 
    CheckDate,
    TableName,
    CheckName,
    RecordsFailed,
    Severity,
    Details
FROM dbo.DataQualityLog
WHERE CheckDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY CheckDate DESC, Severity, RecordsFailed DESC;
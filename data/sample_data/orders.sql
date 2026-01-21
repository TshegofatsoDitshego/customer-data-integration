-- Sample data for SQL Server source
-- Run this in your SQL Server to create sample orders table

CREATE TABLE dbo.OrdersHistory (
    OrderID INT PRIMARY KEY,
    CustomerEmail VARCHAR(255),
    ProductCategory VARCHAR(100),
    OrderAmount DECIMAL(10,2),
    OrderDate DATE,
    Status VARCHAR(50)
);

INSERT INTO dbo.OrdersHistory VALUES
(2001, 'james.smith@email.com', 'Gaming', 899.99, '2023-12-01', 'Completed'),
(2002, 'sarah.j@email.com', 'Sports', 450.00, '2023-12-05', 'Completed'),
(2003, 'm.williams@company.co.za', 'Casino', 1200.00, '2023-12-10', 'Completed'),
(2004, 'david.jones@email.com', 'Gaming', 650.00, '2023-12-15', 'Refunded'),
(2005, 'lisa.garcia@email.com', 'Sports', 320.00, '2023-12-20', 'Completed');
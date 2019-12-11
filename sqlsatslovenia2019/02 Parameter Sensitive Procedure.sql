-------------------------------------------------------------------------------------
-- Sql Saturday Slovenia, 14.12.2019
-- Demystifying Query Store Plan Forcing - Parameter Sensitive Procedure
-- Milos Radivojevic, bwin, Data Platform MVP, Vienna, Austria
-------------------------------------------------------------------------------------
USE WideWorldImporters;
CREATE INDEX ix1 ON Sales.Orders (OrderDate);
GO

CREATE OR ALTER PROCEDURE dbo.GetSalesOrdersSince
@OrderDate DATETIME
AS
SELECT *
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE OrderDate >= @OrderDate
ORDER BY o.ExpectedDeliveryDate DESC;
GO

ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON (
QUERY_CAPTURE_MODE = CUSTOM,
QUERY_CAPTURE_POLICY =(
    EXECUTION_COUNT = 20,
    TOTAL_COMPILE_CPU_TIME_MS = 1000,
    TOTAL_EXECUTION_CPU_TIME_MS = 100,
    STALE_CAPTURE_POLICY_THRESHOLD = 1 day)
)
GO

EXEC dbo.GetSalesOrdersSince '20170101';
GO 20
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC dbo.GetSalesOrdersSince '20120101';
GO 10
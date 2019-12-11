-------------------------------------------------------------------------------------
-- Sql Saturday Slovenia, 14.12.2019
-- Demystifying Query Store Plan Forcing - Forcing Failure - NO_PLAN
-- Milos Radivojevic, bwin, Data Platform MVP, Vienna, Austria
-------------------------------------------------------------------------------------

USE WideWorldImporters;
CREATE INDEX ix1 ON Sales.Orders (OrderDate) WITH (DROP_EXISTING = ON);
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON (
QUERY_CAPTURE_MODE = CUSTOM,
QUERY_CAPTURE_POLICY =(
    EXECUTION_COUNT = 10,
    TOTAL_COMPILE_CPU_TIME_MS = 1000,
    TOTAL_EXECUTION_CPU_TIME_MS = 100,
    STALE_CAPTURE_POLICY_THRESHOLD = 1 day)
)
GO

EXEC dbo.GetSalesOrdersSince '20170101';
GO 10
EXEC sp_query_store_force_plan @query_id = 1, @plan_id = 1;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
CREATE INDEX ix1 ON Sales.Orders(BackorderOrderID) WITH (DROP_EXISTING = ON);
GO
EXEC dbo.GetSalesOrdersSince '20170101';
GO


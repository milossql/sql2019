-------------------------------------------------------------------------------------
-- Sql Saturday Slovenia, 14.12.2019
-- Demystifying Query Store Plan Forcing - Forcing plan (Automatic plan correction online)
-- Milos Radivojevic, bwin, Data Platform MVP, Vienna, Austria
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE = OFF;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON (
QUERY_CAPTURE_MODE = CUSTOM,
QUERY_CAPTURE_POLICY =
(
EXECUTION_COUNT = 20,
TOTAL_COMPILE_CPU_TIME_MS = 1000,
TOTAL_EXECUTION_CPU_TIME_MS = 100,
STALE_CAPTURE_POLICY_THRESHOLD = 1 day
)
)
GO
ALTER DATABASE current SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON); 
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
EXEC dbo.GetSalesOrdersSince '20170101';
GO 1300 
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC dbo.GetSalesOrdersSince '20120101';
GO 20

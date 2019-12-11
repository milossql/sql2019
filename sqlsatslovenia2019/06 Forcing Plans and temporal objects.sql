-------------------------------------------------------------------------------------
-- Sql Saturday Slovenia, 14.12.2019
-- Demystifying Query Store Plan Forcing - Forcing Plans and temporal objects
-- Milos Radivojevic, bwin, Data Platform MVP, Vienna, Austria
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE is_table_type = 1 AND name = N'IntList')
	CREATE TYPE dbo.IntList AS TABLE(
	fValue INT NOT NULL PRIMARY KEY CLUSTERED
	)
GO
CREATE OR ALTER PROCEDURE dbo.GetOrderList (@tvp AS dbo.IntList READONLY)
AS
SELECT o.* FROM Sales.Orders o
INNER JOIN @tvp t on o.OrderID=t.fValue;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON (QUERY_CAPTURE_MODE = AUTO);
GO

--call 
DECLARE @t AS dbo.IntList;
INSERT @t SELECT TOP (10) OrderId FROM Sales.Orders ORDER BY 1 DESC;
EXEC dbo.GetOrderList @t;
GO 3
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
DECLARE @t AS dbo.IntList;
INSERT @t SELECT TOP (2000) OrderId FROM Sales.Orders ORDER BY 1 DESC;
EXEC dbo.GetOrderList @t;
GO

--opposite order
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
DECLARE @t AS dbo.IntList;
INSERT @t SELECT TOP (2000) OrderId FROM Sales.Orders ORDER BY 1 DESC;
EXEC dbo.GetOrderList @t;
GO
DECLARE @t AS dbo.IntList;
INSERT @t SELECT TOP (10) OrderId FROM Sales.Orders ORDER BY 1 DESC;
EXEC dbo.GetOrderList @t;
GO


--now run this again
CREATE OR ALTER PROCEDURE dbo.GetOrderList
(@tvp AS dbo.IntList READONLY)
AS
SELECT o.*
FROM Sales.Orders o
INNER JOIN @tvp t on o.OrderID=t.fValue;
GO
--call 
DECLARE @t AS dbo.IntList;
INSERT @t SELECT TOP (10) OrderId FROM Sales.Orders ORDER BY 1 DESC;
EXEC dbo.GetOrderList @t;
GO 3
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
DECLARE @t AS dbo.IntList;
INSERT @t SELECT TOP (2000) OrderId FROM Sales.Orders ORDER BY 1 DESC;
EXEC dbo.GetOrderList @t;
GO

SELECT qs.query_id, q.query_sql_text, qs.query_hash, qs.batch_sql_handle
FROM sys.query_store_query AS qs
INNER JOIN sys.query_store_query_text AS q ON qs.query_text_id = q.query_text_id
WHERE object_id = OBJECT_ID('dbo.GetOrderList')
ORDER BY qs.last_execution_time DESC
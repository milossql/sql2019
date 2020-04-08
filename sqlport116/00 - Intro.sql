-------------------------------------------------------------------------------------
-- SqlPort 116 Online meeting, 08.04.2020
-- Query Store - Introduction
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
	QUERY_CAPTURE_POLICY = (
	EXECUTION_COUNT = 10,
	TOTAL_COMPILE_CPU_TIME_MS = 1000,
	TOTAL_EXECUTION_CPU_TIME_MS = 100,
	STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS
    )

)
GO


SELECT *
FROM Sales.Orders o WHERE OrderDate>'20200101'
GO 9

--execute the query and click the Cancel Executing Query button
SELECT *
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID;
GO 7

--execute the following query to simulate the Divide by zero error
SELECT TOP (1) OrderID/ (SELECT COUNT(*)
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE o.SalespersonPersonID IN (0,897))
FROM Sales.Orders;
GO 10

--check DMVs
SELECT * FROM sys.query_store_query;

SELECT t.query_sql_text, q.* FROM sys.query_store_query q
INNER JOIN sys.query_store_query_text t ON q.query_text_id = t.query_text_id;

SELECT * FROM sys.query_store_plan;

SELECT * FROM sys.query_store_runtime_stats ORDER BY plan_id;

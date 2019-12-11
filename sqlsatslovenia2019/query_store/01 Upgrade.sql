-------------------------------------------------------------------------------------
-- Sql Saturday Slovenia, 14.12.2019
-- Demystifying Query Store Plan Forcing - Upgrade from CL 110 to CL 150
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
EXECUTION_COUNT = 10,
TOTAL_COMPILE_CPU_TIME_MS = 1000,
TOTAL_EXECUTION_CPU_TIME_MS = 100,
STALE_CAPTURE_POLICY_THRESHOLD = 1 day
)
)
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 110;
GO
--Ensure that the Discard results after execution option is turned on
--run query with CL 110
SELECT *
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE o.PickedByPersonID IN (0, 898);
GO 20

--change CL to the latest one
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO

--run the same query
SELECT *
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE o.PickedByPersonID IN (0, 898);
GO 20
 
 
--------------------------------------------------------------------------------------
---- SqlPort 116 Online meeting, 08.04.2020
---- Query Store - Introduction
---- Milos Radivojevic, bwin, Data Platform MVP, Vienna, Austria
---------------------------------------------------------------------------------------
--USE WideWorldImporters;
--GO
----create a sample table:
----help function GetNums originaly created by Itzik Ben-Gan (http://tsql.solidq.com)
--IF OBJECT_ID('dbo.GetNums') IS NOT NULL DROP FUNCTION dbo.GetNums;
--GO
--CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
--AS
--RETURN
--  WITH
--  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
--  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
--  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
--  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
--  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
--  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
--  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
--  SELECT n FROM Nums WHERE n <= @n;
--GO

----Create a sample table
--DROP TABLE IF EXISTS dbo.Events;
--CREATE TABLE dbo.Events(
--Id INT IDENTITY(1,1) NOT NULL,
--EventType TINYINT NOT NULL,
--EventDate DATETIME NOT NULL,
--Note CHAR(100) NOT NULL DEFAULT 'test',
--CONSTRAINT PK_Events PRIMARY KEY CLUSTERED (id ASC)
--);
--GO
---- Populate the table with 10M rows
--DECLARE @date_from DATETIME = '20000101';
--DECLARE @date_to DATETIME = '20190901';
--DECLARE @number_of_rows INT = 1000000;
--INSERT INTO dbo.Events(EventType,EventDate)
--SELECT 1 + ABS(CHECKSUM(NEWID())) % 5 AS eventtype,
--(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8)) AS INT))%CAST((@date_to - @date_from)AS INT)))) AS EventDate
--FROM dbo.GetNums(@number_of_rows)
--GO
----Create index on the orderdate column
--CREATE INDEX ix1 ON dbo.Events(EventDate);
--GO
--CREATE OR ALTER PROCEDURE dbo.GetEventsSince
--@OrderDate DATETIME
--AS
--BEGIN
--	SELECT * FROM dbo.Events
--	WHERE EventDate >= @OrderDate
--	ORDER BY Note DESC;
--END
--GO


--ensure that db is in CL 140 
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
--setup Query Store
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
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
EXEC dbo.GetEventsSince '20200101'
GO 25 
CREATE OR ALTER PROCEDURE dbo.GetEventsSince
@OrderDate DATETIME
AS
BEGIN
SELECT * FROM dbo.Events
WHERE EventDate >= @OrderDate
ORDER BY Note DESC;
END
GO
EXEC dbo.GetEventsSince '20150101'
GO 3

 
 
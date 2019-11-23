-------------------------------------------------------------------------------------
-- What's New in SQL Server 2019
-- Memory-Optimized TempDB Metadata
-- Slovak SQL Server & BI User Group, 19.11.2019
-- Milos Radivojevic, Data Platform MVP, bwin, Vienna, Austria
-------------------------------------------------------------------------------------
--***********************************************************************************
--					WARNING!!!	
--	DO NOT TRY THIS ON DEV/FUNC or PROD SERVER!!!
--  this is just a demo, you can try it on your machine only!!!
--***********************************************************************************
IF DB_ID('TestDb') IS NULL CREATE DATABASE TestDb;
GO
USE TestDb;
GO
--check the IsTempdbMetadataMemoryOptimized attribute, it should be OFF by default
SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');
GO

--turn on STATISTICS IO in order to see system tables involved in SQL commands
SET STATISTICS IO ON;
 
--create a temp table (you can take any existing table instead of WideWorldImporters.Sales.Orders)
SELECT * INTO #orders 
FROM WideWorldImporters.Sales.Orders;

--check the output in the Messages tab
SELECT * FROM tempdb.sys.tables;
/*Result:
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'sysmultiobjrefs'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'sysschobjs'. Scan count 1, logical reads 37, physical reads 0, page server reads 0, read-ahead reads 24, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syssingleobjrefs'. Scan count 5, logical reads 10, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalnames'. Scan count 1, logical reads 2, physical reads 1, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'sysidxstats'. Scan count 1, logical reads 6, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalvalues'. Scan count 2, logical reads 4, physical reads 1, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/
-- a lot of involved database objects for a very simple action with temp tables
-- when you create, manipulate and drop a lot of temporal objects, these writings into system tables
-- could become a bottleneck in the system (metadata latch contention)

--turn the flag MEMORY_OPTIMIZED TEMPDB_METADATA on
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;

-- restart the server (YOU CAN DO THIS ON YOUR MACHINE ONLY!!!)

--ensure that this query returns 1
SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');

--turn on STATISTICS IO in order to see system tables involved in SQL commands
SET STATISTICS IO ON;
--create a temp table (you can take any existing table instead of WideWorldImporters.Sales.Orders)
SELECT * INTO #orders 
FROM WideWorldImporters.Sales.Orders;

--check the output in the Messages tab
SELECT * FROM tempdb.sys.tables;

/*Result:
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalnames'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalvalues'. Scan count 2, logical reads 4, physical reads 1, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/
--You can see significnatly less objects - most of them are in-memory objects

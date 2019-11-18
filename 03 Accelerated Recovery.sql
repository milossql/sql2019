-------------------------------------------------------------------------------------
-- What's New in SQL Server 2019
-- Accelerated Database Recovery 
-- Slovak SQL Server & BI User Group, 19.11.2019
-- Milos Radivojevic, Data Platform MVP, bwin, Vienna, Austria
-------------------------------------------------------------------------------------

IF DB_ID('TestDb') IS NULL CREATE DATABASE TestDb;
GO
USE TestDb;
GO

--create a new table (you can take any existing table instead of WideWorldImporters.Sales.Orders)
SELECT * INTO dbo.O 
FROM WideWorldImporters.Sales.Orders;
GO
INSERT INTO dbo.O SELECT * FROM dbo.O;
GO 5

--ensure that the ACCELERATED_DATABASE_RECOVERY feature is turned off
ALTER DATABASE TestDb SET ACCELERATED_DATABASE_RECOVERY = OFF;
GO

--run the following two lines
BEGIN TRAN
INSERT INTO dbo.O SELECT * FROM dbo.O;
/* Result:
(2355040 rows affected)
it should take about 20 seconds
*/

--now run the ROLLBACK statement
ROLLBACK;
/* Result:
Commands completed successfully.
the ROLLBACK statement took about 8 seconds
*/

--now turn the ACCELERATED_DATABASE_RECOVERY flag on
--ansure that no other session in this database is active!!!
ALTER DATABASE TestDb SET ACCELERATED_DATABASE_RECOVERY = ON;
GO

--run the following two lines
BEGIN TRAN
INSERT INTO dbo.O SELECT * FROM dbo.O;
/* Result:
(2355040 rows affected)
it should take about 20 seconds
*/

--now run the ROLLBACK statement
ROLLBACK;
/* Result:
Commands completed successfully.
the ROLLBACK is instantaneous!!!
*/

--cleanup
--ensure that you rollback all transactions
ROLLBACK;
/* Result:
Msg 3903, Level 16, State 1, Line 60
The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.
*/

DROP TABLE IF EXISTS dbo.O;

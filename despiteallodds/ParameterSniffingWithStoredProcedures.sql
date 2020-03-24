-------------------------------------------------------------------------------------
-- MS Community BiH Despite All Odds, 24.03.2020
-- Parameter Sniffing in SQL Server Stored Procedures
-- Milos Radivojevic, Principal Database Consultant, bwin.party
-- E: MRadivojevic@gvcgroup.com
-- W: http://www.bwinparty.com 
-------------------------------------------------------------------------------------


IF DB_ID('SearchDemo') IS NULL
	CREATE DATABASE SearchDemo
GO 
USE SearchDemo
GO

IF OBJECT_ID('dbo.GetNums') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
  SELECT n FROM Nums WHERE n <= @n;
GO
 
-- Create a sample table
DROP TABLE IF EXISTS dbo.StudentExams;
CREATE TABLE dbo.StudentExams(
	exam_number int NOT NULL,
	student_id int NOT NULL,
	exam_id tinyint NOT NULL,
	exam_note tinyint NOT NULL,
	exam_date datetime NOT NULL,
	exam_comment char(500) NULL,
 CONSTRAINT PK_StudentExams PRIMARY KEY CLUSTERED (exam_number ASC)
)
GO

--Fill the table
 DECLARE @date_from DATETIME = '19950101';
 DECLARE @date_to DATETIME = '20091231';
 DECLARE @number_of_rows INT = 10000000;
 INSERT INTO dbo.StudentExams
 SELECT n AS exam_number,
    1 + ABS(CHECKSUM(NEWID())) % 500000 AS student_id,
    1 + ABS(CHECKSUM(NEWID())) % 40 AS exam_id,
    5 + ABS(CHECKSUM(NEWID())) % 6 AS exam_note,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) exam_date,
'test'
FROM dbo.GetNums(@number_of_rows)
ORDER BY 1
GO

-- Indexes
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name='ix1')
	CREATE NONCLUSTERED INDEX ix1 
	ON dbo.StudentExams (student_id)
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name='ix2')
	CREATE NONCLUSTERED INDEX ix2 
	ON dbo.StudentExams (exam_date)
GO

------------------------------
--- Default Solution
------------------------------
CREATE OR ALTER PROCEDURE dbo.GetExams
@student_id int = NULL, @exam_date datetime = NULL
AS
BEGIN
	SELECT 
		TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM dbo.StudentExams
	WHERE 
		(student_id = @student_id OR @student_id IS NULL)
	AND 
		(exam_date = @exam_date OR @exam_date IS NULL)
	ORDER BY exam_note DESC;
END
GO
------------------------------------------------------------------------
--- Solution 4: Option RECOMPILE
------------------------------------------------------------------------
ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM dbo.StudentExams
	WHERE 
		(student_id = @student_id OR @student_id IS NULL)
	AND 
		(exam_date = @exam_date OR @exam_date IS NULL)
	ORDER BY exam_note DESC;
END
GO


--Test
 EXEC dbo.getExams NULL, '20050731';
 /*
	Execution time: 180 ms
	Logical reads: 29.742
*/
 EXEC dbo.getExams 2001, NULL;
 /*
	Execution time: 6.445 ms
	Logical reads: 40.647.499
*/
GO
------------------------------------------------------------------------
--- Solution 1: Neutralizing PS ny using the UNKNOWN query hint
------------------------------------------------------------------------
ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM dbo.StudentExams
	WHERE 
		(student_id = @student_id OR @student_id IS NULL)
	AND 
		(exam_date = @exam_date OR @exam_date IS NULL)
	ORDER BY exam_note DESC
	OPTION (OPTIMIZE FOR UNKNOWN)
END
GO

--Test
 EXEC dbo.getExams NULL, '20050731';
 /*
	Execution time: 420 ms
	Logical reads: 681.550
*/
 EXEC dbo.getExams 2001, NULL;
 /*
	Execution time: 505 ms
	Logical reads: 681.550
*/
GO

------------------------------------------------------------------------
--- Solution 2: Neutralizing PS ny using local variables
------------------------------------------------------------------------
ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	DECLARE @student_id_local INT = @student_id, @exam_date_local DATETIME = @exam_date;

	SELECT 
		TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM 
		dbo.StudentExams
	WHERE 
		(student_id = @student_id_local OR @student_id_local IS NULL)
		AND 
		(exam_date = @exam_date_local OR @exam_date_local IS NULL)
	ORDER BY 
		exam_note DESC;
END
GO
--Test
 EXEC dbo.getExams NULL, '20050731';
 /*
	Execution time: 420 ms
	Logical reads: 681.550
*/
 EXEC dbo.getExams 2001, NULL;
 /*
	Execution time: 505 ms
	Logical reads: 681.550
*/
GO
------------------------------------------------------------------------
--- Solution 3: Favorite combinations
------------------------------------------------------------------------
ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM 
		dbo.StudentExams
	WHERE 
		(student_id = @student_id OR @student_id IS NULL)
	AND 
		(exam_date = @exam_date OR @exam_date IS NULL)
	ORDER BY 
		exam_note DESC
	OPTION (OPTIMIZE FOR (@student_id = 1));
END
GO

------------------------------------------------------------------------
--- Solution 4: Option RECOMPILE
------------------------------------------------------------------------
ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM 
	dbo.StudentExams
	WHERE 
		(student_id = @student_id OR @student_id IS NULL)
	AND 
		(exam_date = @exam_date OR @exam_date IS NULL)
	ORDER BY 
		exam_note DESC
	OPTION (RECOMPILE);
END
GO

--Test
 EXEC dbo.getExams NULL, '20050731';
 /*
	Execution time: 36 ms
	Logical reads: 79
*/
 EXEC dbo.getExams 2001, NULL;
 /*
	Execution time: 37 ms
	Logical reads: 7.156
*/
GO
------------------------------------------------------------------------
--- Solution 5: Decision Tree - Static
------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetExams1
@student_id INT
AS
BEGIN
	SELECT TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM dbo.StudentExams
	WHERE student_id = @student_id 
	ORDER BY exam_note DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.GetExams2
@exam_date DATETIME
AS
BEGIN
	SELECT TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM dbo.StudentExams
	WHERE exam_date = @exam_date
	ORDER BY exam_note DESC
END
GO

CREATE OR ALTER PROCEDURE dbo.GetExams3
AS
BEGIN
	SELECT TOP (10) student_id, exam_number, exam_date, exam_note 
	FROM dbo.StudentExams
	ORDER BY exam_note DESC
END
GO

CREATE OR ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	IF @student_id IS NOT NULL
		EXEC dbo.GetExams1 @student_id;	
	ELSE
 		IF @exam_date IS NOT NULL
			EXEC dbo.GetExams2 @exam_date;
		ELSE
			EXEC dbo.GetExams3;
END
GO

--Test
 EXEC dbo.getExams NULL, '20050731';
 /*
	Execution time: 36 ms
	Logical reads: 79
*/
 EXEC dbo.getExams 2001, NULL;
 /*
	Execution time: 43 ms
	Logical reads: 7.036
*/
GO

------------------------------------------------------------------------
--- Solution 6: Decision Tree - Dynamic
------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetExams
@student_id INT = NULL, 
@exam_date DATETIME = NULL
AS
BEGIN
	DECLARE @sql nvarchar(600) = N'SELECT TOP (10) student_id, exam_number, exam_date, exam_note FROM dbo.StudentExams WHERE 1 = 1  '
	IF @student_id IS NOT NULL 
		SET @sql+=' AND student_id = @sid '
	IF @exam_date IS NOT NULL 
		SET @sql+=' AND exam_date = @ed '
	SET @sql+=' ORDER BY exam_note DESC ' 
	
EXEC sp_executesql @sql,  N'@sid INT, @ed DATETIME',  @sid = @student_id, @ed = @exam_date;
END
GO
--Test
 EXEC dbo.getExams NULL, '20050731';
 /*
	Execution time: 36 ms
	Logical reads: 79
*/
 EXEC dbo.getExams 2001, NULL;
 /*
	Execution time: 37 ms
	Logical reads: 7.156
*/
GO

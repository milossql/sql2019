-------------------------------------------------------------------------------------
-- IT-Tage 2019, Frankfurt  11.12.2019
-- Intelligent Query Processing - Scalar UDF Inlining
-- Milos Radivojevic, Data Platform MVP, bwin, Vienna, Austria
-------------------------------------------------------------------------------------

USE WideWorldImporters;
GO

/*******************************************************************************
	create sample tables and functions
*******************************************************************************/
CREATE OR ALTER FUNCTION dbo.Distance (@Lat1 FLOAT, @Lon1 FLOAT, @Lat2 FLOAT, @Lon2 FLOAT)
RETURNS FLOAT
AS
BEGIN;
	DECLARE 
		@Lat1R FLOAT = RADIANS(@Lat1), 
		@Lon1R FLOAT = RADIANS(@Lon1),
		@Lat2R FLOAT = RADIANS(@Lat2),
		@Lon2R FLOAT = RADIANS(@Lon2),
		@DistR FLOAT, @Dist FLOAT;
	SET @DistR = 2 * ASIN(SQRT(POWER(SIN((@Lat1R - @Lat2R) / 2), 2)
	+ (COS(@Lat1R) * COS(@Lat2R) * POWER(SIN((@Lon1R - @Lon2R) / 2), 2))));
	SET @Dist = @DistR * 20001.6 / PI();
	RETURN @Dist;
END;
GO
--Wien (48.210033, 16.363449), Frankfurt (50.110924, 8.682127)
SELECT dbo.Distance(48.210033,16.363449,50.110924, 8.682127);
GO
--596.45791649676 km

USE WideWorldImporters;
--create and populate a sample table
DROP TABLE IF EXISTS dbo.Place;
CREATE TABLE dbo.Place(Id INT PRIMARY KEY CLUSTERED, Lat FLOAT, Lon FLOAT, St CHAR(2));
GO
INSERT INTO dbo.Place
SELECT c.CityID, Location.Lat, Location.Long, sp.StateProvinceCode
FROM Application.Cities c
INNER JOIN Application.StateProvinces sp ON c.StateProvinceID = sp.StateProvinceID;
GO

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
SET STATISTICS TIME ON;
--Ensure that the Discard results after execution option is turned ON
GO
SELECT dbo.Distance(a.Lat, a.Lon, b.Lat, b.Lon)
FROM dbo.Place AS a
CROSS JOIN dbo.Place AS b
WHERE a.St = 'FL' AND b.St = 'FL';
GO

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO

SELECT dbo.Distance(a.Lat, a.Lon, b.Lat, b.Lon)
FROM dbo.Place AS a
CROSS JOIN dbo.Place AS b
WHERE a.St = 'FL' AND b.St = 'FL';
GO

CREATE OR ALTER FUNCTION dbo.Distance2 (@tvp dbo.IntType READONLY, @Lat1 FLOAT, @Lon1 FLOAT, @Lat2 FLOAT, @Lon2 FLOAT)
RETURNS FLOAT
AS
BEGIN;
	DECLARE 
		@Lat1R FLOAT = RADIANS(@Lat1), 
		@Lon1R FLOAT = RADIANS(@Lon1),
		@Lat2R FLOAT = RADIANS(@Lat2),
		@Lon2R FLOAT = RADIANS(@Lon2),
		@DistR FLOAT, @Dist FLOAT;
	SET @DistR = 2 * ASIN(SQRT(POWER(SIN((@Lat1R - @Lat2R) / 2), 2)
	+ (COS(@Lat1R) * COS(@Lat2R) * POWER(SIN((@Lon1R - @Lon2R) / 2), 2))));
	SET @Dist = @DistR * 20001.6 / PI();
	RETURN @Dist;
END;
GO

--check is_inlineable
SELECT CONCAT(SCHEMA_NAME(o.schema_id),'.',o.name), is_inlineable
FROM sys.sql_modules m
INNER JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.type = 'FN'; 
GO
/*
---------------------                    -------------
Website.CalculateCustomerPrice           0
dbo.Distance                             1
dbo.Distance2                            0
*/

CREATE OR ALTER FUNCTION dbo.Distance3 (@Lat1 FLOAT, @Lon1 FLOAT, @Lat2 FLOAT, @Lon2 FLOAT)
RETURNS FLOAT
AS
BEGIN;
	DECLARE @d DATETIME = GETDATE();
	DECLARE 
		@Lat1R FLOAT = RADIANS(@Lat1), 
		@Lon1R FLOAT = RADIANS(@Lon1),
		@Lat2R FLOAT = RADIANS(@Lat2),
		@Lon2R FLOAT = RADIANS(@Lon2),
		@DistR FLOAT, @Dist FLOAT;
	SET @DistR = 2 * ASIN(SQRT(POWER(SIN((@Lat1R - @Lat2R) / 2), 2)
	+ (COS(@Lat1R) * COS(@Lat2R) * POWER(SIN((@Lon1R - @Lon2R) / 2), 2))));
	SET @Dist = @DistR * 20001.6 / PI();
	RETURN @Dist;
END;
GO

--check is_inlineable
SELECT CONCAT(SCHEMA_NAME(o.schema_id),'.',o.name), is_inlineable
FROM sys.sql_modules m
INNER JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.type = 'FN'; 
/*
---------------------                    -------------
Website.CalculateCustomerPrice           0
dbo.Distance                             1
dbo.Distance2                            0
dbo.Distance3                            0
*/

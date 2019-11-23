USE TestDb;
GO
--stored proc
CREATE OR ALTER PROCEDURE dbo.P
AS
DECLARE @cnt INT = 0;
WHILE @cnt < 50
BEGIN
	CREATE TABLE #T (id INT); INSERT INTO #T(id) VALUES(1); DROP TABLE #T;
	SET @cnt+=1
END
GO

SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');
GO

ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
GO

--.\ostress -E -dTestDb -Q"EXEC dbo.P" -SMYSQL2019 -r100 -n100 -q

--check waits
SELECT 
r.wait_time,
r.wait_type, 
r.total_elapsed_time,
r.cpu_time,
st.text,
c.client_net_address,
c.num_reads,
c.num_writes
FROM sys.dm_exec_requests r INNER JOIN sys.dm_exec_connections c
ON (r.connection_id = c.connection_id) OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE 
r.wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP','WAITFOR')
AND r.database_id = DB_ID()
ORDER BY 
 r.wait_time DESC
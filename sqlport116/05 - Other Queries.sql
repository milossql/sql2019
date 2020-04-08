------------------------------------------------------------------------------------
-- SqlPort 116 Online meeting, 08.04.2020
-- Query Store - Introduction
-- Milos Radivojevic, bwin, Data Platform MVP, Vienna, Austria
-------------------------------------------------------------------------------------

--get aborted queries and queries with exceptions
SELECT OBJECT_NAME(object_id) objname, object_id, execution_type_desc, SUM(count_executions) cnt
FROM sys.query_store_runtime_stats rs
INNER JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
INNER JOIN sys.query_store_query q ON p.query_id = q.query_id
WHERE execution_type<>0 AND CAST(first_execution_time AS DATE) = '20191001'
GROUP BY  OBJECT_NAME(object_id), object_id, execution_type_desc;

--get queries with multiple plans
WITH cte AS(
SELECT query_id, COUNT(*) cnt FROM sys.query_store_plan p 
GROUP BY query_id
HAVING COUNT(*) > 10
)
SELECT OBJECT_NAME(object_id) oname,cte.*
FROM sys.query_store_query q 
INNER JOIN cte ON cte.query_id = q.query_id
ORDER BY 2 DESC;

-----------------------------------
--Identifying ad hoc queries
-----------------------------------
SELECT p.query_id 
FROM sys.query_store_plan p 
INNER JOIN sys.query_store_runtime_stats s ON p.plan_id = s.plan_id 
GROUP BY p.query_id 
HAVING SUM(s.count_executions) = 1;
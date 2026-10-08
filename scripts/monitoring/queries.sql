-- Estadísticas de consultas con pg_stat_statements
-- PostgreSQL 17
-- Solo lectura.

-- 1. Consultas con mayor tiempo total acumulado.

SELECT
    queryid,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_ms,
    ROUND(max_exec_time::numeric, 2) AS max_ms,
    rows,
    shared_blks_hit,
    shared_blks_read,
    temp_blks_read,
    temp_blks_written,
    LEFT(query, 300) AS query
FROM pg_stat_statements
WHERE dbid = (
    SELECT oid
    FROM pg_database
    WHERE datname = 'dvdrental'
)
ORDER BY total_exec_time DESC
LIMIT 20;

-- 2. Consultas con mayor tiempo medio.
-- Se exige un mínimo de cinco llamadas para reducir
-- el impacto de ejecuciones aisladas.

SELECT
    queryid,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_ms,
    ROUND(max_exec_time::numeric, 2) AS max_ms,
    rows,
    LEFT(query, 300) AS query
FROM pg_stat_statements
WHERE dbid = (
    SELECT oid
    FROM pg_database
    WHERE datname = 'dvdrental'
)
AND calls >= 5
ORDER BY mean_exec_time DESC
LIMIT 20;

-- 3. Consultas con más bloques temporales escritos.
-- Un valor elevado puede indicar operaciones que usan
-- archivos temporales, por ejemplo sorts o hashes.

SELECT
    queryid,
    calls,
    temp_blks_written,
    temp_blks_read,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    LEFT(query, 300) AS query
FROM pg_stat_statements
WHERE dbid = (
    SELECT oid
    FROM pg_database
    WHERE datname = 'dvdrental'
)
ORDER BY temp_blks_written DESC
LIMIT 20;

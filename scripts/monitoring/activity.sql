-- Actividad y conexiones de PostgreSQL 17
-- Base de laboratorio: dvdrental
-- Solo lectura.

SELECT
    pid,
    usename,
    datname,
    application_name,
    client_addr,
    state,
    xact_start,
    query_start,
    CASE
        WHEN xact_start IS NOT NULL
        THEN clock_timestamp() - xact_start
    END AS transaction_duration,
    CASE
        WHEN query_start IS NOT NULL
         AND state = 'active'
        THEN clock_timestamp() - query_start
    END AS query_duration,
    wait_event_type,
    wait_event,
    LEFT(query, 300) AS query
FROM pg_stat_activity
WHERE datname = 'dvdrental'
ORDER BY
    (state = 'active') DESC,
    query_start ASC NULLS LAST;

-- Resumen de conexiones por estado.

SELECT
    datname,
    usename,
    state,
    COUNT(*) AS sessions
FROM pg_stat_activity
WHERE datname = 'dvdrental'
GROUP BY datname, usename, state
ORDER BY datname, usename, state;

-- Transacciones abiertas durante más de un minuto.
-- Una transacción abierta no siempre es un problema;
-- revisar especialmente las sesiones "idle in transaction".

SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    clock_timestamp() - xact_start AS transaction_duration,
    wait_event_type,
    wait_event,
    LEFT(query, 300) AS query
FROM pg_stat_activity
WHERE datname = 'dvdrental'
  AND xact_start IS NOT NULL
  AND xact_start < clock_timestamp() - INTERVAL '1 minute'
ORDER BY xact_start;

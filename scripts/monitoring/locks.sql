-- Diagnóstico de bloqueos
-- PostgreSQL 17
-- Solo lectura.

SELECT
    blocked.pid AS blocked_pid,
    blocked.usename AS blocked_user,
    blocked.application_name AS blocked_application,
    blocked.state AS blocked_state,
    clock_timestamp() - blocked.query_start AS blocked_query_duration,
    blocked.wait_event_type,
    blocked.wait_event,
    LEFT(blocked.query, 300) AS blocked_query,
    blocker.pid AS blocker_pid,
    blocker.usename AS blocker_user,
    blocker.application_name AS blocker_application,
    blocker.state AS blocker_state,
    blocker.xact_start AS blocker_transaction_start,
    clock_timestamp() - blocker.xact_start
        AS blocker_transaction_duration,
    LEFT(blocker.query, 300) AS blocker_query
FROM pg_stat_activity AS blocked
CROSS JOIN LATERAL
    unnest(pg_blocking_pids(blocked.pid)) AS blocking_pid(pid)
LEFT JOIN pg_stat_activity AS blocker
    ON blocker.pid = blocking_pid.pid
ORDER BY blocked.query_start NULLS LAST;

-- Locks registrados en la base dvdrental.
-- granted = false identifica solicitudes que todavía esperan.

SELECT
    l.pid,
    a.usename,
    l.locktype,
    l.mode,
    l.granted,
    l.relation::regclass AS relation,
    l.transactionid,
    a.state,
    a.wait_event_type,
    a.wait_event,
    LEFT(a.query, 300) AS query
FROM pg_locks AS l
LEFT JOIN pg_stat_activity AS a
    ON a.pid = l.pid
WHERE l.database = (
    SELECT oid
    FROM pg_database
    WHERE datname = 'dvdrental'
)
ORDER BY l.granted, l.pid, l.locktype;

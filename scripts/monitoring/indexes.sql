-- Estadísticas de índices
-- PostgreSQL 17
-- Solo lectura.

-- 1. Uso registrado y tamaño de los índices.

SELECT
    s.schemaname,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    s.idx_scan,
    s.idx_tup_read,
    s.idx_tup_fetch,
    pg_size_pretty(
        pg_relation_size(s.indexrelid)
    ) AS index_size
FROM pg_stat_user_indexes AS s
ORDER BY s.idx_scan DESC, s.relname, s.indexrelname;

-- 2. Índices sin exploraciones registradas.
-- No implica que deban eliminarse.

SELECT
    s.schemaname,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_size_pretty(
        pg_relation_size(s.indexrelid)
    ) AS index_size,
    i.indisprimary AS is_primary_key,
    i.indisunique AS is_unique,
    i.indisvalid AS is_valid
FROM pg_stat_user_indexes AS s
JOIN pg_index AS i
    ON i.indexrelid = s.indexrelid
WHERE s.idx_scan = 0
ORDER BY s.relname, s.indexrelname;

-- 3. Tamaño de las tablas y sus índices.

SELECT
    schemaname,
    relname AS table_name,
    pg_size_pretty(
        pg_table_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        )
    ) AS table_size,
    pg_size_pretty(
        pg_indexes_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        )
    ) AS indexes_size,
    pg_size_pretty(
        pg_total_relation_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        )
    ) AS total_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(
    quote_ident(schemaname) || '.' || quote_ident(relname)
) DESC;

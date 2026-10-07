-- Acceso a la base
GRANT CONNECT ON DATABASE dvdrental TO admin;
GRANT CONNECT ON DATABASE dvdrental TO app_readwrite;
GRANT CONNECT ON DATABASE dvdrental TO app_readonly;
GRANT CONNECT ON DATABASE dvdrental TO backup_user;

-- Esquema
GRANT USAGE ON SCHEMA public TO admin;
GRANT USAGE ON SCHEMA public TO app_readwrite;
GRANT USAGE ON SCHEMA public TO app_readonly;

-- Solo lectura
GRANT SELECT
ON ALL TABLES IN SCHEMA public
TO app_readonly;

-- Lectura y escritura
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO app_readwrite;

-- Secuencias
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA public
TO app_readwrite;

-- Privilegios por defecto
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO app_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO app_readwrite;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT, UPDATE
ON SEQUENCES TO app_readwrite;

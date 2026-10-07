-- Roles funcionales
CREATE ROLE admin NOLOGIN;
CREATE ROLE app_readwrite NOLOGIN;
CREATE ROLE app_readonly NOLOGIN;
CREATE ROLE backup_user NOLOGIN;

-- Capacidades administrativas
ALTER ROLE admin CREATEDB CREATEROLE;

-- Usuarios
CREATE ROLE dba_admin LOGIN IN ROLE admin;
CREATE ROLE app_service LOGIN IN ROLE app_readwrite;
CREATE ROLE reporting_user LOGIN IN ROLE app_readonly;
CREATE ROLE backup_operator LOGIN IN ROLE backup_user;

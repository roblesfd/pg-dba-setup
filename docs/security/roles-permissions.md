# Roles y permisos

## Principio

Los usuarios de PostgreSQL se separan de los roles funcionales.

Los roles funcionales utilizan NOLOGIN y representan conjuntos de privilegios.

Los usuarios utilizan LOGIN y reciben permisos mediante membresía en dichos roles.

## Roles

### admin

Rol administrativo para operaciones normales de PostgreSQL.

No posee SUPERUSER.

Capacidades:

- CREATEDB
- CREATEROLE

### app_readwrite

Rol utilizado por aplicaciones que necesitan leer y modificar información.

### app_readonly

Rol utilizado por consultas, reportes y procesos que únicamente necesitan lectura.

### backup_user

Rol destinado a las operaciones de backup y recuperación.

## Usuarios

| Usuario | Rol |
|---|---|
| dba_admin | admin |
| app_service | app_readwrite |
| reporting_user | app_readonly |
| backup_operator | backup_user |

## Seguridad

El usuario postgres queda reservado para operaciones de bootstrap,
recuperación y administración de emergencia.

Los roles funcionales no permiten LOGIN.

Las contraseñas no se almacenan en scripts ni en Git.

Los privilegios se asignarán siguiendo el principio de mínimo privilegio.

## Permisos sobre dvdrental

| Rol | Base | Esquema | Tablas |
|---|---|---|---|
| admin | CONNECT | USAGE | Administración |
| app_readwrite | CONNECT | USAGE | SELECT, INSERT, UPDATE, DELETE |
| app_readonly | CONNECT | USAGE | SELECT |
| backup_user | CONNECT | - | Según necesidades de backup |

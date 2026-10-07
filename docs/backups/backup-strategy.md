# Estrategia de Backups

## Base de datos

dvdrental

## Tipo

Backup lógico.

## Frecuencia

Diario a las 02:00.

## Formato

La base de datos utiliza el formato PostgreSQL Custom,
compatible con pg_restore.

## Backups globales

Los roles y configuraciones globales necesarias se
respaldan mediante pg_dumpall --globals-only.

## Retención

Se conservan backups durante 7 días.

## Ubicación

/var/backups/postgresql/

## Automatización

Los backups son ejecutados mediante systemd timer.

## Credenciales

Las credenciales utilizadas por pg_dump se almacenan
mediante .pgpass.

Las contraseñas no se almacenan en scripts ni en Git.

## Objetivo

Permitir recuperar la base de datos dvdrental y los
objetos globales necesarios para reconstruir el entorno
PostgreSQL.

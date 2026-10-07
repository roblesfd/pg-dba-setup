# Instalación de PostgreSQL

## Servidor

ubuntu-server-dba-pg

## Sistema operativo

Ubuntu Server 24.04 LTS

## PostgreSQL

PostgreSQL 17

## Instalación

PostgreSQL fue instalado utilizando el repositorio oficial de PostgreSQL para Ubuntu.

## Cluster

Cluster principal:

17/main

## Puerto

5432

## Red

PostgreSQL está configurado para aceptar conexiones locales y conexiones provenientes de la red privada:

192.168.56.0/24

## Autenticación

La autenticación mediante contraseña utiliza SCRAM-SHA-256.

No se utiliza:

- trust
- md5

La cuenta postgres mantiene autenticación peer para administración local del sistema.

## Firewall

El puerto 5432 está permitido únicamente desde:

192.168.56.0/24

PostgreSQL no está expuesto directamente a Internet.

## Directorio de datos

/var/lib/postgresql/17/main

## Configuración

Configuración principal:

/etc/postgresql/17/main/postgresql.conf

Configuración de autenticación:

/etc/postgresql/17/main/pg_hba.conf

## Logging

Se habilitó la recopilación de logs y se configuró rotación diaria.

## Seguridad

El servicio PostgreSQL utiliza el usuario de sistema postgres para administrar sus archivos y procesos.

El usuario administrativo del sistema pgadmin no tiene acceso directo a los archivos internos de PostgreSQL.

La administración de PostgreSQL se realizará mediante roles y privilegios específicos.

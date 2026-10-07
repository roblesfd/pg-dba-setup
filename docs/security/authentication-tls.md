# Autenticación y TLS de PostgreSQL

## Servidor

- Hostname: `ubuntu-server-dba-pg`
- IP privada: `192.168.56.101`
- PostgreSQL: 17
- Puerto: `5432`

## Autenticación

PostgreSQL utiliza `SCRAM-SHA-256` para las conexiones autenticadas mediante contraseña.

No se utilizan:

- `trust`
- `md5`

La cuenta `postgres` utiliza `peer` para la administración mediante Unix socket local.

## TLS

Las conexiones TCP de PostgreSQL requieren TLS.

La configuración utiliza:

- TLS mínimo: 1.2
- Certificado del servidor firmado por una CA propia del laboratorio.
- Verificación del servidor mediante la CA.
- Certificado válido para:
  - `ubuntu-server-dba-pg`
  - `192.168.56.101`

## pg_hba.conf

Las conexiones TCP utilizan `hostssl`, por lo que las conexiones TCP sin TLS no coinciden con las reglas permitidas.

Política:

```text
Unix socket:
postgres → peer
otros usuarios → SCRAM

TCP localhost:
TLS + SCRAM

TCP red privada:
TLS + SCRAM
```

## Certificados

La CA privada se mantiene fuera del repositorio.

El repositorio puede contener únicamente certificados públicos necesarios para reproducir o verificar la configuración.

Las claves privadas no se almacenan en Git.

## Política de acceso

La red PostgreSQL está limitada a:

`192.168.56.0/24`

El firewall UFW también limita el puerto `5432` a esta red.

PostgreSQL no está expuesto directamente a Internet.

## Separación de responsabilidades

TLS proporciona cifrado y autenticación de la identidad del servidor.

SCRAM proporciona autenticación mediante credenciales.

Los roles y privilegios PostgreSQL controlan posteriormente qué operaciones puede realizar cada usuario.

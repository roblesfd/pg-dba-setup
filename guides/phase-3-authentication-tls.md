# Fase 3 — Autenticación, TLS y control de acceso

## 1. Crear estructura para TLS

En `ubuntu-server-dba-pg`:

    sudo install -d -m 755 /etc/postgresql/17/ssl
    sudo install -d -m 700 /etc/postgresql/17/ssl/private

Instalar OpenSSL:

    sudo apt install -y openssl


## 2. Crear la CA privada

Generar la clave privada de la CA:

    sudo openssl genrsa -out /etc/postgresql/17/ssl/private/postgresql-ca.key 4096

Generar el certificado de la CA:

    sudo openssl req -x509 \
      -new \
      -key /etc/postgresql/17/ssl/private/postgresql-ca.key \
      -sha256 \
      -days 3650 \
      -out /etc/postgresql/17/ssl/postgresql-ca.crt \
      -subj "/CN=PostgreSQL DBA Lab Root CA"

Proteger la clave privada:

    sudo chown root:root /etc/postgresql/17/ssl/private/postgresql-ca.key
    sudo chmod 600 /etc/postgresql/17/ssl/private/postgresql-ca.key

    sudo chmod 644 /etc/postgresql/17/ssl/postgresql-ca.crt


## 3. Crear certificado para PostgreSQL

Generar la clave privada del servidor:

    sudo openssl genrsa \
      -out /etc/postgresql/17/ssl/private/server.key \
      3072

Crear la configuración de extensiones del certificado:

    sudo tee /etc/postgresql/17/ssl/server-ext.cnf > /dev/null <<'EOF'
    basicConstraints = CA:FALSE
    keyUsage = digitalSignature, keyEncipherment
    extendedKeyUsage = serverAuth
    subjectAltName = DNS:ubuntu-server-dba-pg, IP:192.168.56.101
    EOF

Generar el CSR:

    sudo openssl req \
      -new \
      -key /etc/postgresql/17/ssl/private/server.key \
      -out /etc/postgresql/17/ssl/server.csr \
      -subj "/CN=ubuntu-server-dba-pg"

Firmar el certificado con nuestra CA:

    sudo openssl x509 \
      -req \
      -in /etc/postgresql/17/ssl/server.csr \
      -CA /etc/postgresql/17/ssl/postgresql-ca.crt \
      -CAkey /etc/postgresql/17/ssl/private/postgresql-ca.key \
      -CAcreateserial \
      -out /etc/postgresql/17/ssl/server.crt \
      -days 825 \
      -sha256 \
      -extfile /etc/postgresql/17/ssl/server-ext.cnf


## 4. Aplicar permisos a certificados y claves

Configurar el directorio privado:

    sudo chown postgres:postgres /etc/postgresql/17/ssl/private
    sudo chmod 700 /etc/postgresql/17/ssl/private

Proteger la clave privada del servidor:

    sudo chown postgres:postgres /etc/postgresql/17/ssl/private/server.key
    sudo chmod 600 /etc/postgresql/17/ssl/private/server.key

Configurar el certificado del servidor:

    sudo chown postgres:postgres /etc/postgresql/17/ssl/server.crt
    sudo chmod 644 /etc/postgresql/17/ssl/server.crt

Configurar el certificado público de la CA:

    sudo chown root:root /etc/postgresql/17/ssl/postgresql-ca.crt
    sudo chmod 644 /etc/postgresql/17/ssl/postgresql-ca.crt

La clave privada de la CA debe permanecer bajo `root`:

    sudo chown root:root /etc/postgresql/17/ssl/private/postgresql-ca.key
    sudo chmod 600 /etc/postgresql/17/ssl/private/postgresql-ca.key


## 5. Configurar PostgreSQL para TLS

Editar:

    sudo nano /etc/postgresql/17/main/postgresql.conf

Agregar o modificar:

    ssl = on
    ssl_cert_file = '/etc/postgresql/17/ssl/server.crt'
    ssl_key_file = '/etc/postgresql/17/ssl/private/server.key'
    ssl_min_protocol_version = 'TLSv1.2'


## 6. Configurar autenticación mediante pg_hba.conf

Editar:

    sudo nano /etc/postgresql/17/main/pg_hba.conf

Configurar:

    # Local Unix socket connections
    local   all             postgres                                peer
    local   all             all                                     scram-sha-256

    # IPv4 local connections - TLS required
    hostssl all             all             127.0.0.1/32            scram-sha-256

    # Private administration/application network - TLS required
    hostssl all             all             192.168.56.0/24         scram-sha-256

La política resultante es:

    Unix socket local       → peer / SCRAM
    TCP localhost           → TLS + SCRAM
    TCP red privada         → TLS + SCRAM
    TCP sin TLS             → rechazado
    Internet                → bloqueado por UFW


## 7. Reiniciar PostgreSQL

    sudo systemctl restart postgresql


## 8. Copiar la CA al cliente

En Arch Linux:

    mkdir -p ~/.postgresql

Copiar el certificado público de la CA:

    scp pgadmin@192.168.56.101:/etc/postgresql/17/ssl/postgresql-ca.crt \
      ~/.postgresql/root.crt

Aplicar permisos:

    chmod 644 ~/.postgresql/root.crt


## 9. Conectarse utilizando TLS

Desde Arch Linux:

    psql \
      "host=192.168.56.101 port=5432 dbname=postgres user=postgres sslmode=verify-full"

La conexión utiliza:

    TLS
    +
    SCRAM-SHA-256
    +
    verificación del certificado del servidor


## 10. Configurar credenciales del cliente

En Arch Linux:

    nano ~/.pgpass

Agregar:

    192.168.56.101:5432:*:postgres:TU_CONTRASEÑA

Proteger el archivo:

    chmod 600 ~/.pgpass

El archivo `.pgpass` nunca debe almacenarse en Git.


## 11. Política de acceso administrativo

La política definida para el proyecto es:

    SSH
      ↓
    Administración del servidor
      ↓
    PostgreSQL
      ↓
    TLS
      ↓
    SCRAM-SHA-256
      ↓
    Roles y privilegios

La cuenta `postgres` utiliza `peer` para administración local mediante Unix socket.

Las conexiones TCP utilizan TLS y SCRAM.

No se utilizan:

    trust
    md5

PostgreSQL no está expuesto directamente a Internet.


## 12. Crear estructura de documentación

    mkdir -p ~/postgresql-dba-project/docs/security
    mkdir -p ~/postgresql-dba-project/config/postgresql/tls
    mkdir -p ~/postgresql-dba-project/guides


## 13. Copiar certificado público al proyecto

    cp /etc/postgresql/17/ssl/postgresql-ca.crt \
      ~/postgresql-dba-project/config/postgresql/tls/


## 14. Crear documentación de autenticación y TLS

    nano ~/postgresql-dba-project/docs/security/authentication-tls.md

Contenido:

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

    Unix socket:
    postgres → peer
    otros usuarios → SCRAM

    TCP localhost:
    TLS + SCRAM

    TCP red privada:
    TLS + SCRAM

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

    Los roles y privilegios PostgreSQL controlarán posteriormente qué operaciones puede realizar cada usuario.


## 15. Guardar la guía reproducible

Crear:

    nano ~/postgresql-dba-project/guides/phase-3-authentication-tls.md

La guía debe contener esta secuencia de implementación.


## 16. Configurar .gitignore para secretos

Desde el repositorio:

    cd ~/postgresql-dba-project

Agregar al `.gitignore`:

    .pgpass
    *.key
    *.csr
    *.srl
    server-ext.cnf


## 17. Guardar cambios en Git

    git add \
      docs/security/authentication-tls.md \
      config/postgresql/tls/postgresql-ca.crt \
      guides/phase-3-authentication-tls.md \
      .gitignore

    git commit -m "Configure PostgreSQL authentication and TLS"


## Política final de la Fase 3

    SSH
    ├── ED25519
    ├── PasswordAuthentication no
    └── PermitRootLogin no

    PostgreSQL
    ├── Unix socket → peer / SCRAM
    ├── TCP localhost → TLS + SCRAM
    ├── TCP 192.168.56.0/24 → TLS + SCRAM
    ├── trust → no
    ├── md5 → no
    └── Internet → no

    TLS
    ├── TLS 1.2+
    ├── CA propia
    ├── Certificado del servidor
    └── Claves privadas fuera de Git

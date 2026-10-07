#!/bin/bash

set -euo pipefail

BACKUP_ROOT="/var/backups/postgresql"
DB_NAME="dvdrental"
DB_USER="backup_operator"
DATE=$(date +"%Y-%m-%d_%H%M%S")

DB_BACKUP_DIR="${BACKUP_ROOT}/dvdrental"
GLOBAL_BACKUP_DIR="${BACKUP_ROOT}/globals"
LOG_FILE="/var/log/postgresql-backup/backup.log"

DB_BACKUP="${DB_BACKUP_DIR}/${DB_NAME}_${DATE}.dump"
GLOBAL_BACKUP="${GLOBAL_BACKUP_DIR}/globals_${DATE}.sql"

mkdir -p "$DB_BACKUP_DIR"
mkdir -p "$GLOBAL_BACKUP_DIR"

echo "[$(date)] Iniciando proceso de respaldo de la db" >> "$LOG_FILE"

pg_dump \
  -h 127.0.0.1 \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -F c \
  -f "$DB_BACKUP"

sudo -u postgres pg_dumpall --globals-only \
  > "$GLOBAL_BACKUP"

find "$DB_BACKUP_DIR" \
  -type f \
  -name "*.dump" \
  -mtime +7 \
  -delete

find "$GLOBAL_BACKUP_DIR" \
  -type f \
  -name "*.sql" \
  -mtime +7 \
  -delete

echo "[$(date)] Respaldo completado de forma exitosa" >> "$LOG_FILE"

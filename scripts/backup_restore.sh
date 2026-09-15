#!/usr/bin/env bash
# ============================================================================
# LOGICHAIN BACKUP & RESTORE AUTOMATION SCRIPT
# Maps to CSE3001 Lab 4 (Simple script to backup database) & Unit 5 Recovery
# ============================================================================

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DB_FILE="logichain.db"
BACKUP_FILE="${BACKUP_DIR}/logichain_backup_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

if [ "$1" == "backup" ] || [ -z "$1" ]; then
    echo "=========================================================="
    echo "Initiating Hot Database Backup..."
    echo "=========================================================="
    if [ -f "$DB_FILE" ]; then
        sqlite3 "$DB_FILE" ".dump" > "$BACKUP_FILE"
        echo "Backup completed successfully -> $BACKUP_FILE"
        echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        echo "Error: Database file $DB_FILE not found. Run schema_loader first."
        exit 1
    fi
elif [ "$1" == "restore" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 restore <backup_file_path>"
        exit 1
    fi
    RESTORE_TARGET="$2"
    echo "Restoring database from $RESTORE_TARGET..."
    rm -f "$DB_FILE"
    sqlite3 "$DB_FILE" < "$RESTORE_TARGET"
    echo "Database restored successfully!"
else
    echo "Usage: $0 [backup|restore <file>]"
fi

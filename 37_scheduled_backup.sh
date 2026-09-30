#!/bin/bash

SOURCE_DIR="${1:-/path/to/project}"
BACKUP_DIR="${2:-/path/to/backups}"
RETENTION_DAYS=30
TIMESTAMP=$(date +%F_%H-%M-%S)
BACKUP_NAME="backup_$(basename "$SOURCE_DIR")_${TIMESTAMP}.tar.gz"
LOGFILE="/var/log/scheduled_backup.log"

mkdir -p "$BACKUP_DIR"

{
echo "==========================================================="
echo " Scheduled Backup - $(date)"
echo " Source: $SOURCE_DIR"
echo " Destination: $BACKUP_DIR/$BACKUP_NAME"
echo "==========================================================="

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

if [[ $? -eq 0 ]]; then
    echo "Backup successful: $BACKUP_DIR/$BACKUP_NAME"
    echo "Backup size: $(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)"
else
    echo "Backup failed."
    exit 1
fi

echo -e "\n--- Cleaning up backups older than $RETENTION_DAYS days ---"
find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime "+$RETENTION_DAYS" -exec rm -f {} \; -exec echo "Removed: {}" \;

echo "Backup process completed at $(date)."
echo "==========================================================="
} >> "$LOGFILE" 2>&1

echo "Backup run complete. See $LOGFILE for details."

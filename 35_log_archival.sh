#!/bin/bash

LOG_DIR="${1:-/var/log}"
ARCHIVE_DIR="${2:-/var/log/archive}"
DAYS_OLD="${3:-7}"
TIMESTAMP=$(date +%F_%H-%M-%S)

mkdir -p "$ARCHIVE_DIR"

echo "==========================================================="
echo " Log Archival - $(date)"
echo " Source: $LOG_DIR | Destination: $ARCHIVE_DIR"
echo " Archiving logs older than $DAYS_OLD day(s)"
echo "==========================================================="

ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
LOG_LIST=$(find "$LOG_DIR" -maxdepth 1 -type f -name "*.log" -mtime "+$DAYS_OLD")

if [[ -z "$LOG_LIST" ]]; then
    echo "No log files older than $DAYS_OLD day(s) found. Nothing to archive."
    exit 0
fi

echo "$LOG_LIST" > /tmp/log_archive_filelist.txt
tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -T /tmp/log_archive_filelist.txt

if [[ $? -eq 0 ]]; then
    echo "Archive created: $ARCHIVE_DIR/$ARCHIVE_NAME"
    echo "Files archived:"
    cat /tmp/log_archive_filelist.txt

    read -rp "Delete original log files after archiving? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        xargs rm -f < /tmp/log_archive_filelist.txt
        echo "Original log files removed."
    fi
else
    echo "Archive creation failed."
fi

rm -f /tmp/log_archive_filelist.txt


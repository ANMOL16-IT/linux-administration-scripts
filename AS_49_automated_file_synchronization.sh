#!/bin/bash
###############################################################################
# 49. Automated File Synchronization
# Synchronizes a source project directory with a backup directory
# using rsync, and logs the result.
# Usage: ./49_sync_backup.sh [source_dir] [backup_dir] [--delete]
###############################################################################


SOURCE="${1:-/mnt/c/Users/sriva/project}"
BACKUP="${2:-/mnt/c/Users/sriva/project_backup}"
EXTRA_OPT=""
[ "$3" = "--delete" ] && EXTRA_OPT="--delete"      # mirror deletions as well
LOG_FILE="$HOME/sync_$(date +%Y%m%d).log"


if ! command -v rsync &>/dev/null; then
     echo "Error: rsync is not installed. Install it with: sudo apt install rsync"
     exit 1
fi


if [ ! -d "$SOURCE" ]; then
     echo "Error: source directory not found: $SOURCE"
     exit 1
fi


mkdir -p "$BACKUP"


echo "Synchronizing:"
echo "   Source : $SOURCE/"
echo "   Backup : $BACKUP/"
echo "-------------------------------------------"


rsync -av $EXTRA_OPT --stats "$SOURCE"/ "$BACKUP"/ | tee -a "$LOG_FILE"
status=${PIPESTATUS[0]}
echo "-------------------------------------------"
if [ "$status" -eq 0 ]; then
       echo "$(date '+%F %T') SUCCESS $SOURCE -> $BACKUP" >> "$LOG_FILE"
       echo "Files synchronized successfully."
else
       echo "$(date '+%F %T') FAILED (rsync exit code $status)" >> "$LOG_FILE"
       echo "Synchronization failed (exit code $status). See $LOG_FILE"
       exit "$status"
fi

#!/bin/bash
###############################################################################
# 41. Archive Old Project Files
# Identifies project files older than a specified number of days and
# moves them to an archive directory (original folder layout is kept).
# Usage: ./41_archive_old_files.sh [days] [project_dir] [archive_dir]
###############################################################################


DAYS="${1:-30}"
PROJECT_DIR="${2:-/mnt/c/Users/sriva/project}"
ARCHIVE_DIR="${3:-/mnt/c/Users/sriva/archive}"
LOG_FILE="$ARCHIVE_DIR/archive_$(date +%Y%m%d).log"


if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
     echo "Error: days must be a number."
     exit 1
fi


if [ ! -d "$PROJECT_DIR" ]; then
     echo "Error: project directory not found: $PROJECT_DIR"
     exit 1
fi


mkdir -p "$ARCHIVE_DIR"


echo "Searching '$PROJECT_DIR' for files older than $DAYS days ..."


moved=0
failed=0


while IFS= read -r -d '' file; do
     rel="${file#$PROJECT_DIR/}"
     dest="$ARCHIVE_DIR/$rel"
     mkdir -p "$(dirname "$dest")"
    # Avoid overwriting an already archived file with the same name
    if [ -e "$dest" ]; then
           dest="${dest}.$(date +%H%M%S)"
    fi


    if mv "$file" "$dest"; then
           echo "$(date '+%F %T') MOVED     $file -> $dest" >> "$LOG_FILE"
           echo "   Archived: $rel"
           ((moved++))
    else
           echo "$(date '+%F %T') FAILED $file" >> "$LOG_FILE"
           echo "   Failed:    $rel"
           ((failed++))
    fi
done < <(find "$PROJECT_DIR" -type f -mtime +"$DAYS" -print0)


echo "-----------------------------------------------"
echo "Files archived : $moved"
echo "Failures            : $failed"
echo "Archive folder : $ARCHIVE_DIR"
echo "Old files archived."

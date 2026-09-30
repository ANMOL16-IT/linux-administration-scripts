#!/bin/bash

TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "==========================================================="
echo " Files modified in the last 24 hours under: $TARGET_DIR"
echo " Generated: $(date)"
echo "==========================================================="

FOUND=$(find "$TARGET_DIR" -type f -mtime -1 2>/dev/null)

if [[ -z "$FOUND" ]]; then
    echo "No files were modified in the last 24 hours."
else
    echo "$FOUND" | while read -r f; do
        printf "%-60s %s\n" "$f" "$(stat -c '%y' "$f" 2>/dev/null || stat -f '%Sm' "$f")"
    done
fi

echo "-----------------------------------------------------------"
echo "Total modified files: $(echo "$FOUND" | grep -c .)"

#!/bin/bash

TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "==========================================================="
echo " Duplicate File Scan in: $TARGET_DIR"
echo " Generated: $(date)"
echo "==========================================================="

declare -A CHECKSUM_MAP
DUPLICATES_FOUND=0

while IFS= read -r -d '' file; do
    checksum=$(sha256sum "$file" | awk '{print $1}')
    if [[ -n "${CHECKSUM_MAP[$checksum]}" ]]; then
        echo "Duplicate found:"
        echo "  Original : ${CHECKSUM_MAP[$checksum]}"
        echo "  Duplicate: $file"
        echo
        ((DUPLICATES_FOUND++))
    else
        CHECKSUM_MAP[$checksum]="$file"
    fi
done < <(find "$TARGET_DIR" -type f -print0)

echo "-----------------------------------------------------------"
if [[ $DUPLICATES_FOUND -eq 0 ]]; then
    echo "No duplicate files found."
else
    echo "Total duplicate files found: $DUPLICATES_FOUND"
fi

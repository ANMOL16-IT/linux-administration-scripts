#!/bin/bash

MODE="$1"
TARGET="$2"
BASELINE_FILE="./integrity_baseline.sha256"

usage() {
    echo "Usage: $0 {baseline|verify} <directory>"
    exit 1
}

[[ -z "$MODE" || -z "$TARGET" ]] && usage
[[ ! -d "$TARGET" ]] && { echo "Error: '$TARGET' is not a valid directory."; exit 1; }

case "$MODE" in
    baseline)
        echo "Creating integrity baseline for: $TARGET"
        find "$TARGET" -type f -exec sha256sum {} \; > "$BASELINE_FILE"
        echo "Baseline saved to $BASELINE_FILE ($(wc -l < "$BASELINE_FILE") files)."
        ;;
    verify)
        if [[ ! -f "$BASELINE_FILE" ]]; then
            echo "Error: No baseline file found ($BASELINE_FILE). Run 'baseline' first."
            exit 1
        fi
        echo "Verifying integrity of files under: $TARGET"
        echo "-----------------------------------------------------------"
        CHANGED=0
        sha256sum -c "$BASELINE_FILE" --quiet 2>/tmp/integrity_errors.log
        if [[ -s /tmp/integrity_errors.log ]]; then
            echo "Issues detected:"
            cat /tmp/integrity_errors.log
            CHANGED=1
        fi
        sha256sum -c "$BASELINE_FILE" 2>/dev/null | grep -v ": OK" | while read -r line; do
            echo "MODIFIED/MISSING: $line"
        done
        if [[ $CHANGED -eq 0 ]]; then
            echo "All files match the baseline. No modifications detected."
        fi
        ;;
    *)
        usage
        ;;
esac


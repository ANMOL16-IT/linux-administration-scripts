#!/bin/bash
# package_update_check.sh
# Checks whether system packages require updates. READ-ONLY --
# never runs apt upgrade / dnf upgrade / brew upgrade / installs anything.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/package_check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


log() {
       echo "$1" | tee -a "$LOG_FILE"
}


log "[$TIMESTAMP] Package update check starting"


if command -v apt >/dev/null 2>&1; then
       log "Package manager detected: apt (Debian/Ubuntu)"
       sudo apt update >/dev/null 2>&1
       UPGRADABLE=$(apt list --upgradable 2>/dev/null | tail -n +2)
elif command -v dnf >/dev/null 2>&1; then
       log "Package manager detected: dnf (RHEL-family)"
       UPGRADABLE=$(dnf check-update 2>/dev/null | tail -n +3)
elif command -v brew >/dev/null 2>&1; then
       log "Package manager detected: brew (macOS)"
       brew update >/dev/null 2>&1
       UPGRADABLE=$(brew outdated)
else
       log "ERROR: No supported package manager found (apt/dnf/brew)."
       exit 1
fi
COUNT=$(echo "$UPGRADABLE" | grep -c . || echo 0)


log "Packages with updates available: $COUNT"
if [ "$COUNT" -gt 0 ]; then
     log "--- Upgradable packages ---"
     echo "$UPGRADABLE" | tee -a "$LOG_FILE"
fi
log "NOTE: This script only reports. Run 'sudo apt upgrade' (or equivalent) manually to apply
updates."

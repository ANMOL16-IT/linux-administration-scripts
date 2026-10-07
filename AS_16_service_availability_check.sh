#!/bin/bash
# service_availability_check.sh
# Checks whether a specified service is active and reports its status.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/service_check.log"
SERVICE=${1:-cron}
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


log() {
     echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}


if ! command -v systemctl >/dev/null 2>&1; then
     # Fallback for systems without systemd (some WSL setups)
     if service "$SERVICE" status >/dev/null 2>&1; then
            log "Service '$SERVICE' appears to be running (service command fallback)."
            exit 0
     else
            log "systemctl unavailable and service fallback failed for '$SERVICE'."
            exit 1
     fi
fi


if ! systemctl list-unit-files | grep -q "^$SERVICE"; then
     log "⚠ Service '$SERVICE' was not found on this system."
     exit 1
fi


ACTIVE=$(systemctl is-active "$SERVICE" 2>/dev/null)
ENABLED=$(systemctl is-enabled "$SERVICE" 2>/dev/null)


if [ "$ACTIVE" = "active" ]; then

       log "✅ Service '$SERVICE' is ACTIVE and running (enabled-at-boot: $ENABLED)"

else

       log "❌ Service '$SERVICE' is INACTIVE / NOT running (enabled-at-boot: $ENABLED)"

fi

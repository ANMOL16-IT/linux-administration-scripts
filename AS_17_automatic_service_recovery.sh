#!/bin/bash
# auto_service_recovery.sh
# Checks a service and restarts it automatically if it is not running.
# IMPORTANT: only ever run against the dummy-test.service created for this
# exercise -- never against ssh/cron/networking or any other real service.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/recovery.log"
SERVICE=${1:-dummy-test}
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


log() {
     echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}


if ! systemctl list-unit-files | grep -q "^$SERVICE"; then
     log "ERROR: Service '$SERVICE' does not exist on this system."
     exit 1
fi


PRIOR_STATE=$(systemctl is-active "$SERVICE" 2>/dev/null)
log "Checked '$SERVICE' -- prior state: $PRIOR_STATE"


if [ "$PRIOR_STATE" = "active" ]; then
     log "Service is healthy, no action needed."
     exit 0
fi


log "Service is down. Attempting restart..."
if sudo systemctl restart "$SERVICE" 2>>"$LOG_FILE"; then
       sleep 2
       NEW_STATE=$(systemctl is-active "$SERVICE" 2>/dev/null)
       if [ "$NEW_STATE" = "active" ]; then

              log "✅ Recovery successful -- '$SERVICE' is now active."

       else

              log "❌ Restart command ran but service still not active (state: $NEW_STATE)."

              exit 1
       fi
else

       log "❌ Restart command failed for '$SERVICE'."

       exit 1
fi

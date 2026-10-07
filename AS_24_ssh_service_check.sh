#!/bin/bash
# ssh_service_check.sh
# Verifies whether SSH is running and reports its current status.
# READ-ONLY: never starts, stops, restarts, enables, or disables SSH.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/ssh_check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


log() {
       echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}


SERVICE=""
for name in ssh sshd; do
       if systemctl list-unit-files 2>/dev/null | grep -q "^$name"; then
            SERVICE=$name
            break
       fi
done


if [ -z "$SERVICE" ]; then
       log "SSH does not appear to be installed on this system (checked 'ssh' and 'sshd')."
       exit 1
fi


ACTIVE=$(systemctl is-active "$SERVICE" 2>/dev/null)
ENABLED=$(systemctl is-enabled "$SERVICE" 2>/dev/null)
LISTENING="NO"
if command -v ss >/dev/null 2>&1 && ss -tlnp 2>/dev/null | grep -q ":22 "; then
       LISTENING="YES"
fi


log "SSH service '$SERVICE' -- active: $ACTIVE, enabled: $ENABLED, listening on :22: $LISTENING"


if [ "$ACTIVE" = "active" ] && [ "$LISTENING" = "YES" ]; then

       log "✅ SSH is fully operational."

else
       log "⚠ SSH is not fully operational -- review the flags above."
fi

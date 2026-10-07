#!/bin/bash
# server_process_check.sh
# Verifies whether a specified application process is running.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/process_check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STRICT=0


if [ "${1:-}" = "-s" ]; then
       STRICT=1
       shift
fi


PROC_NAME=${1:-}


log() {
       echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}


if [ -z "$PROC_NAME" ]; then
       echo "Usage: $0 [-s] <process_name>"
       exit 1
fi


if [ "$STRICT" -eq 1 ]; then
       PIDS=$(pgrep -f -x "$PROC_NAME" 2>/dev/null)
else
       PIDS=$(pgrep -f -i "$PROC_NAME" 2>/dev/null)
fi
if [ -z "$PIDS" ]; then
     log "Process '$PROC_NAME' is NOT running."
     exit 1
fi


COUNT=$(echo "$PIDS" | wc -l)
OLDEST_PID=$(echo "$PIDS" | head -1)
UPTIME=$(ps -o etime= -p "$OLDEST_PID" 2>/dev/null | xargs)


log "Process '$PROC_NAME' is RUNNING -- $COUNT instance(s), PIDs: $(echo $PIDS | tr '\n' ' '),
oldest uptime: $UPTIME"

#!/bin/bash
# multi_server_check.sh
# Checks connectivity to every server listed in servers.txt and reports
# UP/DOWN status for each, with a summary.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/multi_server_check.log"
SERVER_LIST="$PROJECT_DIR/servers.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


if [ ! -f "$SERVER_LIST" ]; then
     echo "ERROR: $SERVER_LIST not found." | tee -a "$LOG_FILE"
     exit 1
fi


UP_COUNT=0
DOWN_COUNT=0
TOTAL=0


echo "[$TIMESTAMP] Multi-server connectivity check" | tee -a "$LOG_FILE"


while IFS= read -r line; do
     # skip comments and blank lines
     [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
     host=$(echo "$line" | xargs)
     TOTAL=$((TOTAL + 1))


     if ping -c 2 "$host" >/dev/null 2>&1; then
          echo "$host -> UP" | tee -a "$LOG_FILE"
          UP_COUNT=$((UP_COUNT + 1))
    else
           echo "$host -> DOWN" | tee -a "$LOG_FILE"
           DOWN_COUNT=$((DOWN_COUNT + 1))
    fi
done < "$SERVER_LIST"


echo "" | tee -a "$LOG_FILE"
echo "Summary: $TOTAL checked, $UP_COUNT UP, $DOWN_COUNT DOWN" | tee -a "$LOG_FILE"

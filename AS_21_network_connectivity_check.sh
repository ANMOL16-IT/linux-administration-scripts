#!/bin/bash
# connectivity_check.sh
# Verifies connectivity to the gateway and a baseline public host via ping.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/connectivity.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
BASELINE_HOST="8.8.8.8"


OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
       PING_FLAG="-c"
else
       PING_FLAG="-c"
fi


GATEWAY=${1:-$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)}


if [ -z "$GATEWAY" ]; then
    echo "ERROR: Could not auto-detect default gateway. Pass a target as \$1." | tee -a
"$LOG_FILE"
       exit 1
fi


check_host() {
       local host=$1
       local label=$2
       local output
       output=$(ping $PING_FLAG 4 "$host" 2>&1)
       local loss rtt
       loss=$(echo "$output" | grep -oP '\d+(?=% packet loss)')
    rtt=$(echo "$output" | tail -1 | awk -F'/' '{print $5}')


    if [ -n "$loss" ] && [ "$loss" -eq 0 ] 2>/dev/null; then

           echo "✅ $label ($host) is REACHABLE (0% loss, avg ${rtt:-?}ms)" | tee -a "$LOG_FILE"

    elif [ -n "$loss" ]; then
           echo "⚠ $label ($host) has PARTIAL loss ($loss%)" | tee -a "$LOG_FILE"
    else

           echo "❌ $label ($host) is UNREACHABLE (100% loss)" | tee -a "$LOG_FILE"

    fi
}


echo "[$TIMESTAMP] Connectivity check starting" | tee -a "$LOG_FILE"
check_host "$GATEWAY" "Gateway"
check_host "$BASELINE_HOST" "Baseline (public DNS)"

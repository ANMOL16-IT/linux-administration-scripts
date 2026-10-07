#!/bin/bash
# port_check.sh
# Checks whether a specified host:port is reachable using bash's /dev/tcp.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/port_check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


check_port() {
       local host=$1
       local port=$2


       if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
              echo "[$TIMESTAMP] Invalid port: $port" | tee -a "$LOG_FILE"
              return 1
       fi


       if timeout 3 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then

              echo "[$TIMESTAMP] ✅ Port $port on $host is OPEN/reachable" | tee -a "$LOG_FILE"

       else

              echo "[$TIMESTAMP] ❌ Port $port on $host is CLOSED/unreachable" | tee -a "$LOG_FILE"

       fi
}


if [ $# -ge 2 ]; then
       check_port "$1" "$2"
else
       echo "No arguments given -- running demo set:" | tee -a "$LOG_FILE"
       check_port "localhost" 22
       check_port "google.com" 443
     check_port "google.com" 12345
fi

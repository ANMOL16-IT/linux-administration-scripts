#!/bin/bash
# high_cpu_detector.sh
# Identifies the top N (default 5) processes consuming the most CPU.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/high_cpu.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COUNT=5
THRESHOLD=50.0


while getopts "n:" opt; do
       case $opt in
              n) COUNT=$OPTARG ;;
       esac
done


if ! command -v ps >/dev/null 2>&1; then
       echo "ERROR: 'ps' command not available on this system."
       exit 1
fi


echo "[$TIMESTAMP] Top $COUNT CPU-consuming processes" | tee -a "$LOG_FILE"


ps -eo pid,ppid,user,%cpu,%mem,comm --sort=-%cpu | head -n $((COUNT + 1)) \
       | awk -v t="$THRESHOLD" -v logf="$LOG_FILE" '
    NR==1 { printf "%-8s %-8s %-12s %-6s %-6s %-20s %s\n",
"PID","PPID","USER","%CPU","%MEM","COMMAND","FLAG"
                  next }
       {
              flag = ($4+0 >= t) ? "<-- HIGH CPU" : ""
              printf "%-8s %-8s %-12s %-6s %-6s %-20s %s\n", $1,$2,$3,$4,$5,$6,flag
              print $0, flag >> logf
   }'

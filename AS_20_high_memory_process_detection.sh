#!/bin/bash
# high_memory_detector.sh
# Identifies the top N (default 5) processes consuming the most memory.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/high_memory.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COUNT=5
THRESHOLD=30.0


while getopts "n:" opt; do
       case $opt in
              n) COUNT=$OPTARG ;;
       esac
done


if ! command -v ps >/dev/null 2>&1; then
       echo "ERROR: 'ps' command not available on this system."
       exit 1
fi


echo "[$TIMESTAMP] System memory overview:" | tee -a "$LOG_FILE"
free -h | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"


echo "Top $COUNT memory-consuming processes:" | tee -a "$LOG_FILE"


ps -eo pid,ppid,user,%mem,%cpu,rss,comm --sort=-%mem | head -n $((COUNT + 1)) \
       | awk -v t="$THRESHOLD" -v logf="$LOG_FILE" '
    NR==1 { printf "%-8s %-8s %-12s %-6s %-6s %-10s %-20s %s\n",
"PID","PPID","USER","%MEM","%CPU","RSS(MB)","COMMAND","FLAG"
                  next }
   {
        rss_mb = $6/1024
        flag = ($4+0 >= t) ? "<-- HIGH MEM" : ""
        printf "%-8s %-8s %-12s %-6s %-6s %-10.1f %-20s %s\n", $1,$2,$3,$4,$5,rss_mb,$7,flag
        print $0, flag >> logf
   }'

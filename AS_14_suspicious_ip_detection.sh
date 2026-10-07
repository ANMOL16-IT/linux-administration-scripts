#!/bin/bash
# suspicious_ip_detector.sh
# Detects IP addresses responsible for repeated failed SSH login attempts.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
mkdir -p "$REPORT_DIR"
THRESHOLD=${2:-5}
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="$REPORT_DIR/suspicious_ip_report_${TIMESTAMP}.log"


# 1. Detect a real log source on this system (override with $1)
detect_logfile() {
     if [ -n "${1:-}" ] && [ -f "$1" ]; then
            echo "$1"
     elif [ -f /var/log/auth.log ]; then
            echo "/var/log/auth.log"
     elif [ -f /var/log/secure ]; then
            echo "/var/log/secure"
     else
            echo ""
     fi
}


LOGFILE=$(detect_logfile "${1:-}")


if [ -z "$LOGFILE" ]; then
     echo "ERROR: No real SSH auth log found on this system." | tee -a "$REPORT_FILE"
     exit 1
fi


if [ ! -r "$LOGFILE" ]; then
     echo "ERROR: Cannot read $LOGFILE (try running with sudo)." | tee -a "$REPORT_FILE"
     exit 1
fi


echo "Log source          : $LOGFILE"          | tee    "$REPORT_FILE"
echo "Threshold            : $THRESHOLD attempts" | tee -a "$REPORT_FILE"
echo "Generated on         : $(date)"           | tee -a "$REPORT_FILE"
echo "-------------------------------------" | tee -a "$REPORT_FILE"


# 2. Extract failed SSH attempts and the source IP, count per IP
RESULTS=$(grep -E "Failed password" "$LOGFILE" 2>/dev/null \
     | grep -oP "(?<=from )\d{1,3}(\.\d{1,3}){3}" \
     | sort | uniq -c | sort -nr)


if [ -z "$RESULTS" ]; then
     echo "No suspicious IP activity found in the current system logs." | tee -a "$REPORT_FILE"
     exit 0
fi


echo "$RESULTS" | awk -v t="$THRESHOLD" '{
     if ($1 >= t) {
         printf "SUSPICIOUS     %-16s   %d failed attempts\n", $2, $1
     } else {
         printf "normal         %-16s   %d failed attempts\n", $2, $1
     }
}' | tee -a "$REPORT_FILE"


echo "-------------------------------------" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE"

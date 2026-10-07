#!/bin/bash
# error_log_report.sh
# Extracts and summarizes error-level messages from a real system log.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
mkdir -p "$REPORT_DIR"
KEYWORDS="error|fail|critical|fatal|warn"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="$REPORT_DIR/error_report_${TIMESTAMP}.log"


detect_logfile() {
     if [ -n "${1:-}" ] && [ -f "$1" ]; then
            echo "$1"
     elif [ -f /var/log/syslog ]; then
            echo "/var/log/syslog"
     elif [ -f /var/log/dpkg.log ]; then
            echo "/var/log/dpkg.log"
     else
            echo ""
     fi
}


LOGFILE=$(detect_logfile "${1:-}")


if [ -z "$LOGFILE" ]; then
     echo "ERROR: No accessible log file found on this system." | tee "$REPORT_FILE"
     exit 1
fi


if [ ! -s "$LOGFILE" ]; then
     echo "Log file $LOGFILE exists but is empty." | tee "$REPORT_FILE"
       exit 0
fi


TOTAL_LINES=$(wc -l < "$LOGFILE")
MATCHES=$(grep -iE "$KEYWORDS" "$LOGFILE")
MATCH_COUNT=$(echo "$MATCHES" | grep -c . || true)


{
echo "SYSTEM LOG ERROR ANALYSIS REPORT"
echo "================================="
echo "Generated on        : $(date)"
echo "Target log file     : $LOGFILE"
echo "Total log lines     : $TOTAL_LINES"
echo "Matching entries : $MATCH_COUNT"
echo ""
echo "--- Breakdown by keyword ---"
for kw in error fail critical fatal warn; do
       c=$(grep -ic "$kw" "$LOGFILE" || echo 0)
       printf "%-10s : %d\n" "$kw" "$c"
done
echo ""
if [ "$MATCH_COUNT" -eq 0 ]; then
       echo "No error-level entries found in the scanned log."
else
       echo "--- 10 most recent matching lines ---"
       echo "$MATCHES" | tail -10
fi
} | tee "$REPORT_FILE"


echo ""
echo "Report saved to: $REPORT_FILE"

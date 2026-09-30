#!/bin/bash

REPORT_DIR="/var/log/health_reports"
TIMESTAMP=$(date +%F_%H-%M-%S)
REPORT_FILE="$REPORT_DIR/health_report_${TIMESTAMP}.txt"

mkdir -p "$REPORT_DIR"

{
echo "==========================================================="
echo " Linux System Health Report"
echo " Generated: $(date)"
echo " Host: $(hostname)"
echo "==========================================================="

echo -e "\n--- Uptime & Load Average ---"
uptime

echo -e "\n--- CPU Usage (snapshot) ---"
top -bn1 | head -5

echo -e "\n--- Memory Usage ---"
free -h

echo -e "\n--- Disk Usage ---"
df -h

echo -e "\n--- Top 5 Memory-Consuming Processes ---"
ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -6

echo -e "\n--- Top 5 CPU-Consuming Processes ---"
ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -6

echo -e "\n--- Network Connections Summary ---"
if command -v ss &>/dev/null; then
    ss -s
else
    netstat -s | head -10
fi

echo -e "\n--- System Errors (last 20 from journal, if available) ---"
if command -v journalctl &>/dev/null; then
    journalctl -p err -n 20 --no-pager 2>/dev/null
else
    echo "journalctl not available."
fi

echo -e "\n==========================================================="
echo " END OF HEALTH REPORT"
echo "==========================================================="
} > "$REPORT_FILE"

echo "Health report generated: $REPORT_FILE"

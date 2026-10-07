#!/bin/bash
###############################################################################
# 48. Administrator Daily Report
# Generates a daily report containing system uptime, CPU, memory,
# disk usage, logged-in users and running services.
# Designed to be run manually or from Cron (e.g. 0 8 * * *).
###############################################################################


REPORT_DIR="${1:-$HOME/admin_reports}"
REPORT_FILE="$REPORT_DIR/daily_report_$(date +%F).txt"


mkdir -p "$REPORT_DIR"


{
echo "===== DAILY ADMIN REPORT ====="
echo "Host : $(hostname)"
echo "Date : $(date)"
echo


echo "Uptime:"
uptime
echo


echo "CPU:"
top -bn1 | grep "Cpu(s)"
echo


echo "Memory:"
free -h
echo


echo "Disk:"
df -h
echo
echo "Users:"
who
echo


echo "Services:"
if command -v systemctl &>/dev/null; then
       systemctl list-units --type=service --state=running 2>/dev/null | head -15
else
       service --status-all 2>/dev/null | head -15
fi
echo
echo "===== END OF REPORT ====="
} | tee "$REPORT_FILE"


echo
echo "Daily report saved to: $REPORT_FILE"

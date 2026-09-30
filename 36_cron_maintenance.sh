#!/bin/bash

LOGFILE="/var/log/cron_maintenance.log"
TIMESTAMP=$(date '+%F %T')

{
echo "==========================================================="
echo " Cron Maintenance Run: $TIMESTAMP"
echo "==========================================================="

echo -e "\n--- Cleaning package manager cache ---"
if command -v apt-get &>/dev/null; then
    sudo apt-get clean -y
    sudo apt-get autoremove -y
elif command -v yum &>/dev/null; then
    sudo yum clean all
elif command -v dnf &>/dev/null; then
    sudo dnf clean all
fi

echo -e "\n--- Removing temporary files older than 7 days ---"
find /tmp -type f -mtime +7 -exec rm -f {} \; 2>/dev/null
echo "Done."

echo -e "\n--- Removing old log files (>30 days) in /var/log ---"
find /var/log -type f -name "*.log" -mtime +30 -exec rm -f {} \; 2>/dev/null
echo "Done."

echo -e "\n--- Disk Usage Summary ---"
df -h

echo -e "\n--- Maintenance completed at $(date '+%F %T') ---"
echo "==========================================================="
} >> "$LOGFILE" 2>&1

echo "Maintenance run complete. See $LOGFILE for details."

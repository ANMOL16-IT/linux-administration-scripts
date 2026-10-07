#!/bin/bash
###############################################################################
# 50. Mini Linux Administration Dashboard
# A Bash-based dashboard that displays CPU usage, memory usage,
# disk usage, logged-in users, running services and system uptime
# in a single report.
###############################################################################


section() {
      echo
      echo "-----------------------------------------------------------"
      echo " $1"
      echo "-----------------------------------------------------------"
}


echo "==========================================================="
echo "               LINUX ADMINISTRATION DASHBOARD"
echo "       Host: $(hostname)      $(date '+%Y-%m-%d %H:%M:%S')"
echo "==========================================================="


section "CPU"
top -bn1 | grep "Cpu(s)"
echo "Load average: $(cut -d' ' -f1-3 /proc/loadavg)         Cores: $(nproc)"


section "Memory"
free -h


section "Disk"
df -h | grep -v -E "tmpfs|udev"


section "Users"
who
echo "Logged-in users: $(who | wc -l)"
section "Services"
if command -v systemctl &>/dev/null; then
       systemctl list-units --type=service --state=running 2>/dev/null | head -10
else
       service --status-all 2>/dev/null | head -10
fi


section "Uptime"
uptime
echo "Up since: $(uptime -s 2>/dev/null || echo 'N/A')"


echo
echo "===========================     END   =========================="

#!/bin/bash

REPORT="/tmp/system_inventory_$(hostname)_$(date +%F_%H-%M-%S).txt"

{
echo "======================================="
echo "       SYSTEM INVENTORY REPORT"
echo "       Generated: $(date)"
echo "======================================="

echo -e "\n--- Hostname ---"
hostname

echo -e "\n--- Operating System ---"
if [[ -f /etc/os-release ]]; then
    grep -E '^(NAME|VERSION)=' /etc/os-release
else
    uname -a
fi

echo -e "\n--- Kernel Version ---"
uname -r

echo -e "\n--- CPU Information ---"
if command -v lscpu &>/dev/null; then
    lscpu | grep -E 'Model name|Socket|Core|Thread'
else
    grep "model name" /proc/cpuinfo | head -1
fi

echo -e "\n--- RAM Information ---"
free -h

echo -e "\n--- Disk Information ---"
df -h --total | grep -E 'Filesystem|total'

echo -e "\n--- Network Information ---"
if command -v ip &>/dev/null; then
    ip -brief addr show
else
    ifconfig
fi

echo -e "\n======================================="
echo "         END OF REPORT"
echo "======================================="
} | tee "$REPORT"

echo
echo "Report saved to: $REPORT"


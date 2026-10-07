#!/bin/bash
###############################################################################
# 44. Resource Threshold Monitor
# Checks CPU and memory usage and displays warnings when either one
# exceeds a specified threshold.
# Usage: ./44_resource_monitor.sh [cpu_threshold] [mem_threshold]     (default: 80 80)
###############################################################################


CPU_THRESHOLD="${1:-80}"
MEM_THRESHOLD="${2:-80}"


for v in "$CPU_THRESHOLD" "$MEM_THRESHOLD"; do
       if ! [[ "$v" =~ ^[0-9]+$ ]]; then
            echo "Error: thresholds must be whole numbers."
            exit 1
       fi
done


# CPU usage = 100 - idle (taken from the "id" value reported by top)
CPU=$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{for (i=1;i<=NF;i++) if ($i=="id") idle=$
(i-1)} END {printf "%.1f", 100-idle}')


# Memory usage = used / total * 100
MEM=$(free | awk '/Mem:/ {printf "%.1f", $3/$2*100}')


echo "==========================================="
echo " Resource Threshold Monitor"
echo " Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "==========================================="
echo "CPU Usage        : ${CPU}%   (threshold: ${CPU_THRESHOLD}%)"
echo "Memory Usage : ${MEM}%       (threshold: ${MEM_THRESHOLD}%)"
echo "-------------------------------------------"


status=0
if [ "${CPU%.*}" -gt "$CPU_THRESHOLD" ]; then
     echo "WARNING: High CPU usage"
     status=1
fi


if [ "${MEM%.*}" -gt "$MEM_THRESHOLD" ]; then
     echo "WARNING: High Memory usage"
     status=1
fi


if [ "$status" -eq 0 ]; then
     echo "OK: CPU and memory usage are within limits."
fi


exit $status

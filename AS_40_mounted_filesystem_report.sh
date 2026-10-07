#!/bin/bash
###############################################################################
# 40. Mounted File System Report
# Displays all mounted file systems along with their type, total size,
# used space, available space and mount point.
###############################################################################


echo "==========================================================="
echo " Mounted File System Report"
echo " Host: $(hostname)      Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "==========================================================="


echo -e "\nMounted File Systems:"
df -h


echo -e "\n--- Detailed Report (type, total, used, available) ---"
printf "%-28s %-10s %8s %8s %8s %6s     %s\n" "FILESYSTEM" "TYPE" "TOTAL" "USED" "AVAIL" "USE%"
"MOUNTED ON"
printf "%-28s %-10s %8s %8s %8s %6s     %s\n" "----------" "----" "-----" "----" "-----" "----"
"----------"


df -hT | tail -n +2 | while read -r fs type size used avail pcent mount; do
    printf "%-28s %-10s %8s %8s %8s %6s     %s\n" "$fs" "$type" "$size" "$used" "$avail" "$pcent"
"$mount"
done


echo -e "\n--- Summary ---"
total_fs=$(df -h | tail -n +2 | wc -l)
echo "Total mounted file systems : $total_fs"
echo "Total real disk capacity      : $(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | tail -1 |
awk '{print $2}')"
echo "Total real disk used          : $(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | tail -1 |
awk '{print $3}')"
echo "Total real disk available     : $(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | tail -1 |
awk '{print $4}')"

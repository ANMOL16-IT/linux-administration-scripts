#!/bin/bash
###############################################################################
# 39. Disk and Inode Check
# Checks both disk space and inode utilization for every mounted file
# system and reports the ones exceeding a specified threshold.
# Usage: ./39_disk_inode_check.sh [threshold_percent]       (default: 80)
###############################################################################


THRESHOLD="${1:-80}"


if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
       echo "Error: threshold must be a whole number between 1 and 100."
       exit 1
fi


echo "==========================================================="
echo " Disk & Inode Check     (threshold: ${THRESHOLD}%)"
echo " Host: $(hostname)       Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "==========================================================="


echo -e "\nDisk Usage:"
df -h


echo -e "\nInode Usage:"
df -i


# Skip pseudo file systems so only real storage is evaluated
EXCLUDE="-x tmpfs -x devtmpfs -x squashfs -x overlay"


echo -e "\n--- File systems above ${THRESHOLD}% DISK usage ---"
disk_alerts=$(df -P $EXCLUDE | awk -v t="$THRESHOLD" 'NR>1 { gsub("%","",$5); if ($5+0 >= t)
printf " [ALERT] %-30s %s%% used (%s)\n", $6, $5, $1 }')
if [ -n "$disk_alerts" ]; then
       echo "$disk_alerts"
else
       echo "   All file systems are below the disk-space threshold."
fi


echo -e "\n--- File systems above ${THRESHOLD}% INODE usage ---"
inode_alerts=$(df -iP $EXCLUDE | awk -v t="$THRESHOLD" 'NR>1 { gsub("%","",$5); if ($5 != "-" &&
$5+0 >= t) printf " [ALERT] %-30s %s%% inodes used (%s)\n", $6, $5, $1 }')
if [ -n "$inode_alerts" ]; then
       echo "$inode_alerts"
else
       echo "   All file systems are below the inode threshold."
fi


echo -e "\nCheck complete."

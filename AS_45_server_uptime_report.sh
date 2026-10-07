#!/bin/bash
###############################################################################
# 45. Server Uptime Report
# Reports server uptime and identifies whether the system has been
# running continuously beyond a specified period.
# Usage: ./45_uptime_report.sh [limit_in_hours]      (default: 24)
###############################################################################


LIMIT_HOURS="${1:-24}"


if ! [[ "$LIMIT_HOURS" =~ ^[0-9]+$ ]]; then
       echo "Error: limit must be a whole number of hours."
       exit 1
fi


# Total uptime in seconds, straight from the kernel
UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)


DAYS=$((UPTIME_SECONDS / 86400))
HOURS=$(((UPTIME_SECONDS % 86400) / 3600))
MINS=$(((UPTIME_SECONDS % 3600) / 60))
TOTAL_HOURS=$((UPTIME_SECONDS / 3600))


echo "==========================================="
echo " Server Uptime Report"
echo " Host: $(hostname)"
echo "==========================================="
echo "Server Uptime:"
uptime
echo
echo "Up since          : $(uptime -s 2>/dev/null || echo 'N/A')"
echo "Uptime (pretty): ${DAYS} day(s), ${HOURS} hour(s), ${MINS} minute(s)"
echo "Total hours       : ${TOTAL_HOURS}"
echo "Limit checked     : ${LIMIT_HOURS} hour(s)"
echo "-------------------------------------------"


if [ "$TOTAL_HOURS" -gt "$LIMIT_HOURS" ]; then
       echo "Server has been running for more than ${LIMIT_HOURS} hours."
       echo "Consider scheduling a reboot or maintenance window."
else
       echo "Server uptime is less than ${LIMIT_HOURS} hours."
fi

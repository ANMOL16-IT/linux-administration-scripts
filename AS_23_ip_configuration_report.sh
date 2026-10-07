#!/bin/bash
# ip_config_report.sh
# Displays hostname, IP address, active interfaces, and default gateway.


set -uo pipefail


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
mkdir -p "$REPORT_DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="$REPORT_DIR/ip_config_${TIMESTAMP}.log"


if ! command -v ip >/dev/null 2>&1; then
    echo "ERROR: 'ip' command not available. Try the ifconfig-based fallback." | tee
"$REPORT_FILE"
       exit 1
fi


{
echo "IP CONFIGURATION REPORT"
echo "========================"
echo "Generated on      : $(date)"
echo "Hostname          : $(hostname)"
echo "All IPs           : $(hostname -I 2>/dev/null)"
echo ""
echo "--- Active interfaces ---"
ip -br addr show up
echo ""
echo "--- Default gateway ---"
ip route | grep default
echo ""
echo "--- DNS servers ---"
if [ -f /etc/resolv.conf ]; then
       grep nameserver /etc/resolv.conf
else
     echo "No /etc/resolv.conf found."
fi
} | tee "$REPORT_FILE"


echo ""
echo "Report saved to: $REPORT_FILE"

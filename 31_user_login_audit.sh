#!/bin/bash

REPORT="/tmp/login_audit_$(date +%F_%H-%M-%S).txt"

{
echo "==========================================================="
echo " User Login Audit Report - $(date)"
echo "==========================================================="

echo -e "\n--- Last Logins (last utility) ---"
sudo wtmpdb last -a | head -n 25

echo -e "\n--- Currently Logged-in Users ---"
who

echo -e "\n--- Failed Login Attempts ---"
if [[ -f /var/log/auth.log ]]; then
    grep "Failed password" /var/log/auth.log | tail -n 25
elif [[ -f /var/log/secure ]]; then
    grep "Failed password" /var/log/secure | tail -n 25
else
    echo "No accessible auth log found (requires root privileges or a different log path)."
fi

echo -e "\n--- Last Reboot / Shutdown History ---"
sudo wtmpdb last reboot | head -n 5
sudo wtmpdb last shutdown | head -n 5

echo -e "\n==========================================================="
echo " END OF AUDIT REPORT"
echo "==========================================================="
} | tee "$REPORT"

echo
echo "Report saved to: $REPORT"


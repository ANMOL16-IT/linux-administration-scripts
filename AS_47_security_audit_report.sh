#!/bin/bash
###############################################################################
# 47. Security Audit Report
# Reports passwordless accounts, world-writable files, failed logins
# and currently active users. Run with sudo for complete results.
# Usage: sudo ./47_security_audit.sh [directory_to_scan]
###############################################################################


SCAN_DIR="${1:-/mnt/c/Users/sriva}"
REPORT="./security_audit_$(date +%Y%m%d_%H%M%S).txt"


{
echo "===== SECURITY AUDIT ====="
echo "Host: $(hostname)       Date: $(date)"
echo


echo "Passwordless Accounts:"
if [ -r /etc/shadow ]; then
       result=$(awk -F: '$2=="" {print "   " $1}' /etc/shadow)
       [ -n "$result" ] && echo "$result" || echo "    None found."
else
       result=$(sudo awk -F: '$2=="" {print "    " $1}' /etc/shadow 2>/dev/null)
       [ -n "$result" ] && echo "$result" || echo "    None found (or insufficient privileges)."
fi
echo


echo "Accounts with UID 0 (root privileges):"
awk -F: '$3==0 {print "     " $1}' /etc/passwd
echo


echo "World Writable Files (in $SCAN_DIR, first 20):"
files=$(find "$SCAN_DIR" -type f -perm -002 2>/dev/null | head -20)
[ -n "$files" ] && echo "$files" || echo "       None found."
echo
echo "Failed Logins:"
if command -v lastb &>/dev/null; then
       failed=$(lastb 2>/dev/null | head -10)
       [ -n "$failed" ] && echo "$failed" || echo "   No failed login records."
else
       echo "   lastb command not available."
fi
echo


echo "Active Users:"
who
echo
echo "===== END OF AUDIT ====="
} | tee "$REPORT"


echo
echo "Audit report saved to: $REPORT"

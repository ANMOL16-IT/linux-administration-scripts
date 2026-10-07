#!/bin/bash
###############################################################################
# 46. Service Status Dashboard
# A simple Bash dashboard that shows the status of SSH, the web
# server and other specified services.
# Edit the SERVICES list to monitor additional services.
###############################################################################


# service-name : label shown on the dashboard
SERVICES=("ssh:SSH" "apache2:Apache Web Server" "nginx:Nginx Web Server" "cron:Cron Scheduler"
"mysql:MySQL Database")


GREEN="\033[0;32m"; RED="\033[0;31m"; YELLOW="\033[0;33m"; NC="\033[0m"


check_service() {
       local svc="$1"
       if [ -d /run/systemd/system ] && command -v systemctl &>/dev/null; then
              # systemd is running: look the unit up first, then ask for its state
              if ! systemctl list-unit-files "${svc}.service" 2>/dev/null | grep -q "${svc}.service";
then
                     echo "not-installed"
              else
                     systemctl is-active "$svc" 2>/dev/null
              fi
       elif pgrep -x "$svc" &>/dev/null; then
              echo "active"
       elif command -v service &>/dev/null && service "$svc" status &>/dev/null; then
              echo "active"
       elif [ -e "/etc/init.d/$svc" ]; then
              echo "inactive"
       else
              echo "not-installed"
       fi
}
echo "==========================================================="
echo "              SERVICE STATUS DASHBOARD   -   $(date '+%Y-%m-%d %H:%M:%S')"
echo "==========================================================="
printf "%-28s %-16s\n" "SERVICE" "STATUS"
echo "-----------------------------------------------------------"


running=0; stopped=0; missing=0


for entry in "${SERVICES[@]}"; do
       svc="${entry%%:*}"
       label="${entry##*:}"
       state=$(check_service "$svc")


       case "$state" in
              active)        printf "%-28s ${GREEN}%-16s${NC}\n"    "$label" "Running";       ((running+
+)) ;;
              not-installed) printf "%-28s ${YELLOW}%-16s${NC}\n" "$label" "Not Installed";    ((missing+
+)) ;;
              *)             printf "%-28s ${RED}%-16s${NC}\n"      "$label" "Not Running";    ((stopped+
+)) ;;
       esac
done


echo "-----------------------------------------------------------"
echo "Running: $running          Not running: $stopped      Not installed: $missing"

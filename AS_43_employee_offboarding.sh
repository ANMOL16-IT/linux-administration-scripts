#!/bin/bash
###############################################################################
# 43. Employee Offboarding
# Disables a specified user account and preserves the user's
# home-directory data for administrative purposes.
# Usage: sudo ./43_offboard_user.sh <username>
###############################################################################


USER_NAME="$1"
BACKUP_DIR="/var/backups/offboarded"
LOG_FILE="/var/log/offboarding.log"


if [[ $EUID -ne 0 ]]; then
     echo "Error: this script must be run as root (use sudo)."
     exit 1
fi


if [ -z "$USER_NAME" ]; then
     echo "Usage: sudo $0 <username>"
     exit 1
fi


if ! id "$USER_NAME" &>/dev/null; then
     echo "Error: user '$USER_NAME' does not exist."
     exit 1
fi


if [ "$USER_NAME" = "root" ]; then
     echo "Error: refusing to disable the root account."
     exit 1
fi


HOME_DIR=$(getent passwd "$USER_NAME" | cut -d: -f6)
echo "Offboarding user: $USER_NAME"


# 1. Lock the password and set the account to expire immediately
usermod -L "$USER_NAME"
usermod -e 1 "$USER_NAME"
echo "     [OK] Password locked and account expired."


# 2. Replace the login shell so no interactive login is possible
usermod -s /usr/sbin/nologin "$USER_NAME"
echo "     [OK] Login shell set to /usr/sbin/nologin."


# 3. Terminate any active sessions
if pgrep -u "$USER_NAME" >/dev/null; then
       pkill -KILL -u "$USER_NAME"
       echo "   [OK] Active sessions terminated."
fi


# 4. Preserve the home directory (compressed archive; original is kept)
if [ -d "$HOME_DIR" ]; then
       mkdir -p "$BACKUP_DIR"
       ARCHIVE="$BACKUP_DIR/${USER_NAME}_$(date +%Y%m%d_%H%M%S).tar.gz"
       tar -czf "$ARCHIVE" -C "$(dirname "$HOME_DIR")" "$(basename "$HOME_DIR")" 2>/dev/null
       echo "   [OK] Home directory preserved at $HOME_DIR"
       echo "   [OK] Backup archive created: $ARCHIVE"
else
       echo "   [WARN] Home directory not found: $HOME_DIR"
fi


echo "$(date '+%F %T') Offboarded user $USER_NAME" >> "$LOG_FILE"


echo
echo "User $USER_NAME has been disabled."
echo "Home directory is preserved."

#!/bin/bash
###############################################################################
# 42. Department Folder Creation
# Automatically creates folders for multiple departments and assigns
# the appropriate group ownership and permissions.
# Usage: sudo ./42_department_folders.sh [base_directory]
###############################################################################


BASE_DIR="${1:-/mnt/c/Users/sriva/departments}"
DEPARTMENTS=("HR" "IT" "Finance" "Sales")


if [[ $EUID -ne 0 ]]; then
       echo "Note: not running as root - group creation and ownership changes will be skipped."
       IS_ROOT=0
else
       IS_ROOT=1
fi


mkdir -p "$BASE_DIR" || { echo "Error: cannot create $BASE_DIR"; exit 1; }


for dept in "${DEPARTMENTS[@]}"; do
       group="$(echo "$dept" | tr '[:upper:]' '[:lower:]')_dept"
       folder="$BASE_DIR/$dept"


       # 1. Create the folder
       mkdir -p "$folder"
       echo "Folder ready   : $folder"


       if [ "$IS_ROOT" -eq 1 ]; then
           # 2. Create the group if it does not exist
           if ! getent group "$group" >/dev/null; then
                groupadd "$group" && echo "Group created : $group"
           fi
            # 3. Assign group ownership (may be unsupported on Windows drives)
            if chgrp "$group" "$folder" 2>/dev/null; then
                   # 4. Group read/write/execute + setgid so new files inherit the group
                   chmod 2770 "$folder"
                   echo "Ownership set : $folder -> group $group (mode 2770)"
            else
                   echo "Warning: could not change group on $folder (file system may not support it)."
            fi
       fi
done


echo
echo "Department folders created."
ls -ld "$BASE_DIR"/*

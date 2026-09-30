#!/bin/bash

echo "==========================================================="
echo " Currently Logged-in Users Report - $(date)"
echo "==========================================================="
printf "%-15s %-12s %-20s %-15s\n" "USER" "TERMINAL" "LOGIN TIME" "SOURCE HOST/IP"
echo "-----------------------------------------------------------"

who | while read -r user tty rest; do
    login_time=$(echo "$rest" | awk '{print $1, $2, $3}')
    source_host=$(echo "$rest" | grep -oP '(?<=\().*(?=\))')
    [[ -z "$source_host" ]] && source_host="local"
    printf "%-15s %-12s %-20s %-15s\n" "$user" "$tty" "$login_time" "$source_host"
done

echo "-----------------------------------------------------------"
echo "Total logged-in sessions: $(who | wc -l)"


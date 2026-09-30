#!/bin/bash

REQUIRED_APPS=("git" "curl" "wget" "vim" "nginx" "python3")

MISSING=()

echo "Checking required applications..."
echo "-----------------------------------"

for app in "${REQUIRED_APPS[@]}"; do
    if command -v "$app" &>/dev/null; then
        echo "[OK]      $app is installed."
    else
        echo "[MISSING] $app is NOT installed."
        MISSING+=("$app")
    fi
done

echo "-----------------------------------"

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All required applications are installed."
else
    echo "Missing packages (${#MISSING[@]}):"
    for m in "${MISSING[@]}"; do
        echo "  - $m"
    done
fi


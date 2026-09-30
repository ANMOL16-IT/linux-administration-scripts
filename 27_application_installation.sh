#!/bin/bash

APPROVED_PACKAGES=("nginx" "apache2" "curl" "git" "vim" "htop")

if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt-get"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="sudo yum install -y"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "No supported package manager found (apt-get/yum/dnf)."
    exit 1
fi

show_menu() {
    echo "==========================================="
    echo " Approved Package Installer ($PKG_MANAGER)"
    echo "==========================================="
    local i=1
    for pkg in "${APPROVED_PACKAGES[@]}"; do
        echo "$i) $pkg"
        ((i++))
    done
    echo "$i) Exit"
    echo "==========================================="
}

while true; do
    show_menu
    read -rp "Select a package to install (number): " choice

    if [[ "$choice" -eq $((${#APPROVED_PACKAGES[@]}+1)) ]]; then
        echo "Exiting installer."
        break
    fi

    if [[ "$choice" -ge 1 && "$choice" -le ${#APPROVED_PACKAGES[@]} ]]; then
        selected="${APPROVED_PACKAGES[$((choice-1))]}"
        echo "Installing $selected ..."
        $INSTALL_CMD "$selected"

        if [[ $? -eq 0 ]]; then
            echo "$selected installed successfully."
        else
            echo "Failed to install $selected."
        fi
    else
        echo "Invalid selection. Please try again."
    fi

    echo
done

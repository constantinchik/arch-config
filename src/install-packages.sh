#!/bin/bash

echo "Installing packages..."
# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Function to install Arch Linux packages
install_arch_packages() {
    xargs -a "$SCRIPT_DIR/arch_pacman_packages.txt" sudo pacman -Syu
    xargs -a "$SCRIPT_DIR/arch_yay_packages.txt" yay -Syu
}

# Run the function
install_arch_packages

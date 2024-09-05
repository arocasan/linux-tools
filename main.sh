#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PKG_DIR="${SCRIPT_DIR}/packages"
# Source the install_packages script
source "$SCRIPT_DIR/install_packages.sh"


source ./scripts/packages.sh
echo "Welcome"
info_msg "Heyo"
install_packages "$PKG_DIR/aroca_pkgs.conf" "$PKG_DIR/aroca_aur_pkgs.conf"
install_packages_scripted "$PKG_DIR/aroca_script_pkgs.conf"

info_msg "Lets go dark mode"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

info_msg "mounting backups"
sudo ntfs-3g /dev/sdc1 ~/backup 


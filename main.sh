#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PKG_DIR="${SCRIPT_DIR}/packages"
# Source the install_packages script
source "$SCRIPT_DIR/install_packages.sh"


source ./scripts/packages.sh
source ./scripts/vm_defeniton.sh

echo "Welcome"
info_msg "Heyo"
install_packages "$PKG_DIR/aroca_pkgs.conf" "$PKG_DIR/aroca_aur_pkgs.conf"
install_packages_scripted "$PKG_DIR/aroca_script_pkgs.conf"

info_msg "Lets go dark mode"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

info_msg "Set symbolic wallpaper as bakground"
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/symbolic-l.png'

info_msg "Disable sleep inactivity"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

info_msg "Disable power button"
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'

info_msg "Disable screen blackout"
gsettings set org.gnome.desktop.session idle-delay 0

info_msg "Setting keyboard input to Swedish Mac"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'se+mac')]"

info_msg "virsh isolated network defenition"
sudo virsh net-define /tmp/isolated.xml

info_msg "mounting backups"
sudo ntfs-3g /dev/sdc1 ~/backup


# Ask for confirmation
read -p "Do you want to proceed with full virsh setup" answer

# Check if the answer is 'y' or 'Y'
if [[ $answer == [Yy] ]]; then
    echo "Proceeding with rsync..."
    sudo rsync -avzt --progress --partial ~/backup/ubuntu-backup/vms/* /var/lib/libvirt/images

    virsh_define

else
    echo "Operation cancelled."
fi

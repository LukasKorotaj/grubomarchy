#!/usr/bin/env bash

# ==============================================================================
# Omarchy SDDM + Plymouth Setup (for non-encrypted disks)
# ==============================================================================

# ------------------------------
# 1. Plymouth theme setup
# ------------------------------
PLYMOUTH_THEME="omarchy"

if [ "$(plymouth-set-default-theme)" != "$PLYMOUTH_THEME" ]; then
    sudo cp -r "$HOME/.local/share/omarchy/default/plymouth" "/usr/share/plymouth/themes/$PLYMOUTH_THEME/"
    sudo plymouth-set-default-theme "$PLYMOUTH_THEME"
    sudo mkinitcpio -P
    echo "Plymouth theme set to $PLYMOUTH_THEME."
fi

# ------------------------------
# 2. Install and enable SDDM
# ------------------------------
if ! command -v sddm &>/dev/null; then
    sudo pacman -S --needed sddm
fi

sudo systemctl enable sddm.service
sudo systemctl set-default graphical.target
echo "SDDM enabled and set as default graphical target."

# ------------------------------
# 3. Remove any previous auto-login config
# ------------------------------
SDDM_CONF_DIR="/etc/sddm.conf.d"
AUTO_CONF="$SDDM_CONF_DIR/omarchy-autologin.conf"

if [ -f "$AUTO_CONF" ]; then
    sudo rm "$AUTO_CONF"
    echo "Removed SDDM auto-login config to require user login."
fi

# ------------------------------
# 4. Plymouth + SDDM integration
# ------------------------------
# Plymouth quits automatically when graphical.target is reached
echo "Plymouth splash will remain until SDDM starts. User will now be prompted to log in."

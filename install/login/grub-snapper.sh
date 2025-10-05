#!/bin/bash
set -euo pipefail
clear

# Ensure user input variables are set
: "${USE_BTRFS:?Please run user-input.sh first}"
: "${SEPARATE_HOME:?Please run user-input.sh first}"

# Check for GRUB installation
if command -v grub-install &>/dev/null; then
  echo "[Omarchy] Detected GRUB, configuring…"

  # --- mkinitcpio hooks ---
  HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block filesystems fsck)
  if [ "$USE_BTRFS" = true ]; then
    HOOKS+=(btrfs)
  fi

  sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf >/dev/null <<EOF
HOOKS=(${HOOKS[*]})
EOF

  # --- Install required packages ---
  PKGS=(grub)
  if [ "$USE_BTRFS" = true ]; then
    PKGS+=(btrfs-progs grub-btrfs snapper inotify-tools)
  fi
  sudo pacman -S --noconfirm --needed "${PKGS[@]}"

  # --- Set up Snapper configs based on user input ---
  if [ "$USE_BTRFS" = true ]; then
    if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
      sudo snapper -c root create-config /
    fi

    if [ "$SEPARATE_HOME" = false ] && ! sudo snapper list-configs 2>/dev/null | grep -q "home"; then
      sudo snapper -c home create-config /home
    fi

    # Tune Snapper defaults
    ROOT_CONFIGS="/etc/snapper/configs/root"
    sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' "$ROOT_CONFIGS"
    sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' "$ROOT_CONFIGS"
    sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' "$ROOT_CONFIGS"

    if [ "$SEPARATE_HOME" = false ]; then
      HOME_CONFIGS="/etc/snapper/configs/home"
      sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' "$HOME_CONFIGS"
      sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' "$HOME_CONFIGS"
      sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' "$HOME_CONFIGS"
    fi

    # Enable grub-btrfs daemon
    sudo systemctl enable --now grub-btrfsd.service
  fi

  # --- GRUB defaults ---
  sudo tee /etc/default/grub >/dev/null <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="Omarchy"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# Graphical console
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep

# Enable Btrfs snapshots submenu if applicable
GRUB_BTRFS_SHOW_SNAPSHOTS=$USE_BTRFS

# Enable OS prober
GRUB_DISABLE_OS_PROBER=false

# Theme (Tokyo Night colors approximated)
GRUB_COLOR_NORMAL="light-cyan/black"
EOF

  # --- Install GRUB ---
  if [[ -d /sys/firmware/efi ]]; then
    echo "[Omarchy] Installing GRUB for EFI"
    sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Omarchy
  else
    echo "[Omarchy] Installing GRUB for BIOS"
    sudo grub-install --target=i386-pc "$(findmnt -n -o SOURCE / | sed 's/p\?[0-9]*$//')"
  fi

  # --- Generate GRUB config ---
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  echo "[Omarchy] GRUB setup complete."
fi

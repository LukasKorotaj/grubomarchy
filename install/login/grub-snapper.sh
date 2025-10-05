if command -v grub-install &>/dev/null; then
  echo "[Omarchy] Detected GRUB, configuring…"

  # --- mkinitcpio hooks ---
  sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<EOF >/dev/null
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block filesystems fsck btrfs)
EOF

  # --- Install required packages ---
  sudo pacman -S --noconfirm --needed grub grub-btrfs snapper inotify-tools os-prober

  # --- Set up Snapper configs ---
  if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
    sudo snapper -c root create-config /
  fi
  if ! sudo snapper list-configs 2>/dev/null | grep -q "home"; then
    sudo snapper -c home create-config /home
  fi

  # Tune Snapper defaults (reduce snapshot spam)
  sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/{root,home}
  sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/{root,home}
  sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/{root,home}

  # --- GRUB defaults ---
  sudo tee /etc/default/grub <<EOF >/dev/null
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="Omarchy"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# Graphical console
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep

# Enable Btrfs snapshots submenu
GRUB_BTRFS_SHOW_SNAPSHOTS=true

# Enable OS prober
GRUB_DISABLE_OS_PROBER=false

# Theme (Tokyo Night colors approximated)
GRUB_COLOR_NORMAL="light-cyan/black"
EOF

  # --- Enable grub-btrfs daemon (dynamic snapshot menu updates) ---
  sudo systemctl enable --now grub-btrfsd.service

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

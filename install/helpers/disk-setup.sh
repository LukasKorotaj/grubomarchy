#!/bin/bash
clear

# Optionally re-print your logo if you have a clear_logo function
if declare -f clear_logo &>/dev/null; then
  clear_logo
fi

# Ask if the user is using a Btrfs filesystem
USE_BTRFS=false
if gum confirm "Are you using a Btrfs filesystem?"; then
  USE_BTRFS=true
fi

# Only ask about separate /home if Btrfs is being used
SEPARATE_HOME=false
if [ "$USE_BTRFS" = true ]; then
  if gum confirm "Have you mounted a non-Btrfs /home?"; then
    SEPARATE_HOME=true
  fi
fi

echo
echo "Btrfs: $USE_BTRFS"
echo "Separate /home: $SEPARATE_HOME"

# Export variables so they can be used by other scripts
export USE_BTRFS
export SEPARATE_HOME

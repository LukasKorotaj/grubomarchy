#!/bin/bash
# Clear any previous clutter
clear

# Optionally, re-print your logo
clear_logo

# Ask for name
if [ -z "$OMARCHY_USER_NAME" ]; then
  export OMARCHY_USER_NAME=$(gum input \
    --placeholder "Enter full name" \
    --prompt "Name> ")
fi

# Ask for email
if [ -z "$OMARCHY_USER_EMAIL" ]; then
  export OMARCHY_USER_EMAIL=$(gum input \
    --placeholder "Enter email address" \
    --prompt "Email> ")
fi

echo # Ensure we end with a positive exit

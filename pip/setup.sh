#!/usr/bin/bash
# Replace pip config in Linux environment

# Set path for the pip config file
PIP_CONFIG_PATH="$HOME/.config/pip/pip.conf"

# Set path for the new pip config file
NEW_CONFIG_PATH="/path/to/new/pip.conf"

# Check if the pip config directory exists
if [ ! -d "$HOME/.config/pip" ]; then
    echo "Creating pip config directory..."
        mkdir -p "$HOME/.config/pip"
        fi

# Check if a current pip config file exists, back it up if needed
if [ -f "$PIP_CONFIG_PATH" ]; then
    echo "Backing up existing pip config..."
    mv "$PIP_CONFIG_PATH" "$PIP_CONFIG_PATH.bak"
fi

# Copy new pip config to the target location
echo "Replacing pip config with new file..."
cp "$NEW_CONFIG_PATH" "$PIP_CONFIG_PATH"

# Confirm operation success
if [ -f "$PIP_CONFIG_PATH" ]; then
   echo "Pip configuration replaced successfully."
   else
   echo "Failed to replace pip configuration."
fi

              

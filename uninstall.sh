#!/bin/bash

# Komkom Uninstaller
# Removes the komkom command line tool

set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="komkom"
CONFIG_DIR="$HOME/.komkom"

echo "🗑️  Starting Komkom uninstallation..."

# Check permissions
if [[ "$EUID" -eq 0 ]]; then
    echo "❌ Don't run this script as root"
    echo "   This script uses sudo only when necessary to remove system files."
    exit 1
fi

# Remove the komkom script
if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
    echo "📋 Removing komkom command..."
    sudo rm "$INSTALL_DIR/$SCRIPT_NAME"
    echo "✅ Command removed from $INSTALL_DIR"
else
    echo "ℹ️  Command not found in $INSTALL_DIR"
fi

# Ask user about config directory
if [[ -d "$CONFIG_DIR" ]]; then
    echo ""
    read -p "❓ Do you want to remove configuration directory ($CONFIG_DIR)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        echo "✅ Configuration directory removed"
    else
        echo "ℹ️  Configuration directory kept"
    fi
fi

echo ""
echo "✅ Komkom uninstalled successfully!"
echo "👋 Goodbye!"

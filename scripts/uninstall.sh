#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Uninstallation
# Removes all installed components

set -e

echo "🗑️  AdminHub Uninstallation"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./uninstall.sh"
    exit 1
fi

echo "This will remove:"
echo "  • LaunchAgents"
echo "  • Guest setup scripts"
echo "  • Admin tools directory"
echo "  • Logs and temporary files"
echo ""
echo -n "Continue? (y/N): "
read -r response
if [[ ! "$response" =~ ^[yY]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Remove LaunchAgents
launchctl unload /Library/LaunchAgents/com.adminhub.guestsetup.plist 2>/dev/null || true
rm -f /Library/LaunchAgents/com.adminhub.guestsetup.plist
rm -f /Library/LaunchAgents/com.adminhub.guestterminal.plist

# Remove scripts
rm -f /usr/local/bin/guest_login_setup
rm -f /usr/local/bin/guest_setup_auto.sh
rm -f /usr/local/bin/guest_setup_final.sh
rm -f /usr/local/bin/guest_setup_background.sh
rm -f /usr/local/bin/guest_tools_setup.sh
rm -f /usr/local/bin/simple_guest_setup.sh
rm -f /usr/local/bin/open_guest_terminal

# Remove admin tools
rm -rf /opt/admin-tools

# Clean up logs
rm -f /tmp/adminhub-*.log
rm -f /tmp/adminhub-*.err
rm -rf /var/log/adminhub

echo "✅ Uninstallation completed!"
echo ""
echo "Note: Homebrew and packages (git, python) were NOT removed."
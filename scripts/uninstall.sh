#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Uninstallation
# Removes all installed components

set -e

echo "╔═══════════════════════════════════════╗"
echo "║      🗑️  AdminHub Uninstallation      ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./uninstall.sh"
    exit 1
fi

echo "⚠️  WARNING: This will remove all AdminHub components!"
echo -n "Continue? (y/N): "
read -r response
if [[ ! "$response" =~ ^[yY]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🧹 Removing components..."

# Remove LaunchAgents
echo "  • Removing LaunchAgents..."
launchctl unload /Library/LaunchAgents/com.adminhub.guestsetup.plist 2>/dev/null || true
rm -f /Library/LaunchAgents/com.adminhub.guestsetup.plist
rm -f /Library/LaunchAgents/com.adminhub.guestterminal.plist

# Remove scripts
echo "  • Removing scripts..."
rm -f /usr/local/bin/guest_login_setup
rm -f /usr/local/bin/guest_setup_auto.sh
rm -f /usr/local/bin/guest_setup_final.sh
rm -f /usr/local/bin/guest_setup_background.sh
rm -f /usr/local/bin/guest_tools_setup.sh
rm -f /usr/local/bin/simple_guest_setup.sh
rm -f /usr/local/bin/open_guest_terminal

# Remove admin tools (optional)
echo ""
echo -n "Also remove admin tools in /opt/admin-tools/? (y/N): "
read -r response
if [[ "$response" =~ ^[yY]$ ]]; then
    echo "  • Removing admin tools..."
    rm -rf /opt/admin-tools
fi

# Clean up logs
echo "  • Cleaning up logs..."
rm -f /tmp/adminhub-*.log
rm -f /tmp/adminhub-*.err

echo ""
echo "✅ Uninstallation completed!"
echo ""
echo "Note: Homebrew and installed packages were NOT removed."
echo "If you want to remove them too, run: brew uninstall git python" 
#!/bin/bash

# AdminHub Master Installation Script
# This script installs the complete AdminHub system on a new MacBook

set -e  # Exit on error

echo "🚀 AdminHub Installation Script"
echo "==============================="
echo ""

# Check if running as sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./install_adminhub.sh"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Prerequisites checked"
echo ""

# Make all scripts executable
echo "📝 Making scripts executable..."
chmod +x *.sh

# Run main setup
echo "🔧 Running main setup..."
./guest_tools_setup.sh

# Fix permissions
echo "🔐 Fixing Homebrew permissions..."
./fix_homebrew_permissions.sh

# Install LaunchAgent if not already installed
if [ ! -f "/Library/LaunchAgents/com.adminhub.guestterminal.plist" ]; then
    echo "📋 Installing LaunchAgent..."
    cp com.adminhub.guestterminal.plist /Library/LaunchAgents/
    chmod 644 /Library/LaunchAgents/com.adminhub.guestterminal.plist
    launchctl load /Library/LaunchAgents/com.adminhub.guestterminal.plist 2>/dev/null || true
fi

echo ""
echo "✅ Installation Complete!"
echo ""
echo "Next steps:"
echo "1. Log out of your current account"
echo "2. Log in as Guest"
echo "3. Terminal will open automatically with development tools ready"
echo ""
echo "Installed tools:"
echo "  • Python 3 with pip"
echo "  • Git"
echo "  • Node.js with npm"
echo "  • jq (JSON processor)"
echo "  • wget"
echo ""
echo "For troubleshooting, see SETUP_README.md" 
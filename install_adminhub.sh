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

# Setup PATH for current user (non-Guest)
echo "🔄 Setting up PATH for immediate use..."

# Get the original user who ran sudo
ORIGINAL_USER=$(who am i | awk '{print $1}')
USER_HOME=$(eval echo ~$ORIGINAL_USER)

# Add to PATH for current session
export PATH="/opt/admin-tools/bin:$PATH"

# Update shell configuration files
if [ -f "$USER_HOME/.zshrc" ]; then
    # Check if already added
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.zshrc"; then
        echo "" >> "$USER_HOME/.zshrc"
        echo "# AdminHub tools" >> "$USER_HOME/.zshrc"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.zshrc"
        echo "✅ Added to .zshrc"
    fi
fi

if [ -f "$USER_HOME/.bash_profile" ]; then
    # Check if already added
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.bash_profile"; then
        echo "" >> "$USER_HOME/.bash_profile"
        echo "# AdminHub tools" >> "$USER_HOME/.bash_profile"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.bash_profile"
        echo "✅ Added to .bash_profile"
    fi
fi

echo ""
echo "🎉 Tools are now available!"
echo ""
echo "Available commands:"
echo "  • python3 - Python 3 with pip3"
echo "  • git - Version control"
echo "  • node - Node.js runtime"
echo "  • npm - Node package manager"
echo "  • jq - JSON processor"
echo "  • wget - File downloader"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ To use tools IMMEDIATELY in THIS terminal:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run this command (copy & paste):"
echo ""
echo "  source activate_tools.sh"
echo ""
echo "OR just open a new Terminal window/tab"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For Guest users:"
echo "1. Log out and log in as Guest"
echo "2. Terminal will open automatically with all tools ready"
echo ""
echo "For troubleshooting, see SETUP_README.md" 
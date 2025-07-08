#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Main Installation Script
# This script installs the complete AdminHub system

set -e  # Exit on error

echo "🚀 AdminHub Installation Script"
echo "==============================="
echo "© 2025 Luka Löhr"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./install_adminhub.sh"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Prerequisites checked"
echo ""

# Make all scripts executable
echo "📝 Making scripts executable..."
find scripts -name "*.sh" -type f -exec chmod +x {} \;

# Run main setup
echo "🔧 Running main setup..."
./scripts/setup/guest_tools_setup.sh

# Fix permissions
echo "🔐 Fixing Homebrew permissions..."
./scripts/utils/fix_homebrew_permissions.sh

# Note: LaunchAgent installation is now handled by setup_guest_shell_init.sh
# Run this script for permission-free guest setup

echo ""
echo "✅ Installation completed!"
echo ""

# Set up PATH for current user (not Guest)
echo "🔄 Setting up PATH for immediate use..."

# Determine original user who ran sudo
ORIGINAL_USER=$(who am i | awk '{print $1}')
USER_HOME=$(eval echo ~$ORIGINAL_USER)

# Add PATH for current session
export PATH="/opt/admin-tools/bin:$PATH"

# Update shell configuration files
if [ -f "$USER_HOME/.zshrc" ]; then
    # Check if already added
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.zshrc"; then
        echo "" >> "$USER_HOME/.zshrc"
        echo "# AdminHub Tools" >> "$USER_HOME/.zshrc"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.zshrc"
        echo "✅ Added to .zshrc"
    fi
fi

if [ -f "$USER_HOME/.bash_profile" ]; then
    # Check if already added
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.bash_profile"; then
        echo "" >> "$USER_HOME/.bash_profile"
        echo "# AdminHub Tools" >> "$USER_HOME/.bash_profile"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.bash_profile"
        echo "✅ Added to .bash_profile"
    fi
fi

echo ""
echo "🎉 Tools are now available!"
echo ""
echo "Available commands:"
echo "  • brew - Homebrew package manager"
echo "  • python3 - Python 3 programming language"
echo "  • python - Python programming language"
echo "  • git - Version control"
echo "  • pip3 - Python 3 package installer"
echo "  • pip - Python package installer"
echo ""

# Create installation test script
cat > /tmp/test_adminhub.sh << 'EOF'
#!/bin/bash
clear
echo "🚀 AdminHub Tools Ready!"
echo "========================"
echo "© 2025 Luka Löhr"
echo ""
export PATH="/opt/admin-tools/bin:$PATH"

echo "📋 Installed Tools:"
echo ""

if command -v python3 &> /dev/null; then
    echo "  ✅ Python $(python3 --version 2>&1 | cut -d' ' -f2)"
else
    echo "  ❌ Python3 not found"
fi

if command -v git &> /dev/null; then
    echo "  ✅ Git $(git --version | cut -d' ' -f3)"
else
    echo "  ❌ Git not found"
fi

if command -v brew &> /dev/null; then
    echo "  ✅ Homebrew $(brew --version 2>&1 | head -1)"
else
    echo "  ❌ Homebrew not found"
fi

if command -v python &> /dev/null; then
    echo "  ✅ Python $(python --version 2>&1 | cut -d' ' -f2)"
else
    echo "  ❌ Python not found"
fi

if command -v pip3 &> /dev/null; then
    echo "  ✅ pip3 $(pip3 --version | cut -d' ' -f2)"
else
    echo "  ❌ pip3 not found"
fi

if command -v pip &> /dev/null; then
    echo "  ✅ pip $(pip --version | cut -d' ' -f2)"
else
    echo "  ❌ pip not found"
fi

echo ""
echo "🎉 All tools are ready!"
echo ""
echo "Try these commands:"
echo "  • brew --version"
echo "  • python3 --version"
echo "  • python --version"
echo "  • git status"
echo ""

# Cleanup
rm /tmp/test_adminhub.sh

# Note: We no longer use AppleScript for terminal management
EOF

chmod +x /tmp/test_adminhub.sh

# Open new terminal and run test script (without AppleScript)
# Skip this if called from AdminHub CLI
if [ "$ADMINHUB_CLI_INSTALL" != "true" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 Opening new terminal with ready tools..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "➡️  New terminal opens in 2 seconds"
    echo ""
    sleep 2
    /usr/bin/open -a Terminal /tmp/test_adminhub.sh
    echo "✅ New terminal opened!"
    echo ""
    echo "This window closes in 5 seconds..."
fi
echo ""
echo "For Guest users:"
echo "1. Log out and log in as Guest"
echo "2. Terminal opens automatically with all tools"
echo ""
echo "For problems see docs/SETUP_README.md" 
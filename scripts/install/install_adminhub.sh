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
./scripts/setup/guest_tools_setup.sh

# Fix permissions
echo "🔐 Fixing Homebrew permissions..."
./scripts/utils/fix_homebrew_permissions.sh

# Note: LaunchAgent installation is now handled by setup_guest_shell_init.sh
# Run that script for the permission-free Guest setup

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

# Create a script to test the installation
cat > /tmp/test_adminhub.sh << 'EOF'
#!/bin/bash
clear
echo "🚀 AdminHub Tools Ready!"
echo "========================"
echo ""
export PATH="/opt/admin-tools/bin:$PATH"

echo "📋 Installed tools:"
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

if command -v node &> /dev/null; then
    echo "  ✅ Node.js $(node --version 2>/dev/null || echo 'installed')"
else
    echo "  ❌ Node not found"
fi

if command -v npm &> /dev/null; then
    echo "  ✅ npm $(npm --version 2>/dev/null || echo 'installed')"
else
    echo "  ❌ npm not found"
fi

echo ""
echo "🎉 All tools are ready to use!"
echo ""
echo "Try these commands:"
echo "  • python3 --version"
echo "  • git status"
echo "  • node --version"
echo ""

# Clean up
rm /tmp/test_adminhub.sh

# Note: We no longer use AppleScript to manage Terminal windows
EOF

chmod +x /tmp/test_adminhub.sh

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Opening new Terminal with tools ready..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "➡️  New Terminal opens in 2 seconds"
echo "➡️  Old Terminals close automatically after 5 seconds"
echo ""
sleep 2

# Open new Terminal and run test script (without AppleScript)
/usr/bin/open -a Terminal /tmp/test_adminhub.sh

echo "✅ New Terminal opened!"
echo ""
echo "This window will close in 5 seconds..."
echo ""
echo "For Guest users:"
echo "1. Log out and log in as Guest"
echo "2. Terminal opens automatically with all tools ready"
echo ""
echo "For troubleshooting, see docs/SETUP_README.md" 
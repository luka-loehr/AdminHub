#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Main Installation Script
# This script installs the complete AdminHub system
# Enhanced with comprehensive support for old Macs (4+ years without updates)

set -e  # Exit on error

echo "🚀 Installing AdminHub..."
echo "Version: 2.1.0 (with old Mac support)"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./install_adminhub.sh"
    exit 1
fi

# Make all scripts executable
find scripts -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null

# Step 1: Run compatibility check for old Macs
echo "🔍 Checking system compatibility..."
if ./scripts/utils/old_mac_compatibility.sh; then
    echo "✅ System compatibility check passed"
else
    echo "❌ System compatibility check failed"
    echo ""
    echo "Please review the compatibility report at:"
    echo "  /tmp/adminhub_compatibility_report.txt"
    echo ""
    echo -n "Continue anyway? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[yY]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

# Step 2: Run system repairs for old Macs
echo ""
echo "🔧 Running system repairs..."
if ./scripts/utils/system_repair.sh; then
    echo "✅ System repairs completed"
else
    echo "⚠️  Some system repairs failed, but continuing..."
fi

# Step 3: Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo ""
    echo "❌ Homebrew is not installed. Please install first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Step 4: Fix Homebrew issues on older Macs
echo ""
echo "🍺 Repairing Homebrew..."
if ./scripts/utils/homebrew_repair.sh; then
    echo "✅ Homebrew repair completed"
else
    echo "⚠️  Homebrew repair encountered issues, but continuing with installation..."
fi

# Step 5: Run main setup
echo ""
echo "📦 Installing AdminHub tools..."
./scripts/setup/guest_tools_setup.sh

# Step 6: Setup security wrappers
echo ""
echo "🔒 Setting up security wrappers..."
./scripts/utils/guest_security_wrapper.sh

# Step 7: Fix permissions
echo ""
echo "🔐 Fixing permissions..."
./scripts/utils/fix_homebrew_permissions.sh

# Verify symlinks are created correctly
echo ""
echo "🔍 Verifying installation..."
VERIFY_FAILED=false

# Check critical symlinks
for tool in brew python python3 pip pip3 git; do
    if [ -L "/opt/admin-tools/bin/$tool" ] && [ -e "/opt/admin-tools/bin/$tool" ]; then
        echo "   ✅ $tool: OK"
    elif [ -e "/opt/admin-tools/bin/$tool" ]; then
        echo "   ⚠️  $tool: exists but may need fixing"
    else
        echo "   ❌ $tool: missing"
        VERIFY_FAILED=true
    fi
done

# Note: LaunchAgent installation is now handled by setup_guest_shell_init.sh
# Run this script for permission-free guest setup

echo ""
if [ "$VERIFY_FAILED" = true ]; then
    echo "⚠️  Installation completed with warnings. Some tools may need manual configuration."
    echo "   Run 'sudo ./scripts/adminhub-cli.sh status' to check system health."
else
    echo "✅ Installation completed successfully!"
fi
echo ""

# Set up PATH for current user (not Guest)

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
    fi
fi

if [ -f "$USER_HOME/.bash_profile" ]; then
    # Check if already added
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.bash_profile"; then
        echo "" >> "$USER_HOME/.bash_profile"
        echo "# AdminHub Tools" >> "$USER_HOME/.bash_profile"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.bash_profile"
    fi
fi


echo ""
echo "Next: Run 'sudo ./scripts/adminhub-cli.sh status' to verify installation" 
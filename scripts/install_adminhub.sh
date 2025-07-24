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

# Check Command Line Tools (optional warning)
if command -v xcode-select &> /dev/null; then
    CLT_VERSION=$(xcode-select --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "0")
    if [ "$CLT_VERSION" -lt 2395 ]; then
        echo ""
        echo "⚠️  Outdated Command Line Tools detected"
        echo "   Consider updating via Software Update or:"
        echo "   sudo rm -rf /Library/Developer/CommandLineTools"
        echo "   sudo xcode-select --install"
        echo ""
        echo "   Continuing with installation..."
    fi
fi

# Step 4: Fix Homebrew issues on older Macs
echo ""
echo "🍺 Repairing Homebrew..."

# First, ensure Homebrew path is correct
BREW_PATH=$(which brew 2>/dev/null || echo "")
if [ -n "$BREW_PATH" ]; then
    # Check if brew command actually works
    if ! brew --version &>/dev/null; then
        echo "⚠️  Homebrew command found but not working properly"
        
        # Try to fix common issues
        if [ -d "/usr/local/Homebrew" ] && [ ! -d "/usr/local/Library" ]; then
            echo "   Detected non-standard Homebrew installation"
            # Create symlink for Library if needed
            ln -s "/usr/local/Homebrew/Library" "/usr/local/Library" 2>/dev/null || true
        fi
    fi
fi

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

# Step 6b: Fix brew wrapper if needed (temporary fix until wrapper script is updated)
echo ""
echo "🔧 Ensuring wrappers use dynamic path detection..."
if [ -f "/opt/admin-tools/wrappers/brew" ]; then
    # Check if brew wrapper has the old hardcoded path
    if grep -q "ACTUAL_BREW=\"/opt/admin-tools/actual/bin/brew\"" "/opt/admin-tools/wrappers/brew" 2>/dev/null; then
        echo "   Updating brew wrapper with dynamic detection..."
        cat > /opt/admin-tools/wrappers/brew << 'EOF'
#!/bin/bash
# Homebrew wrapper for Guest users - blocks system modifications

# Find the actual brew executable
find_actual_brew() {
    # First check if we have a direct symlink
    if [ -L "/opt/admin-tools/actual/bin/brew" ]; then
        local target=$(readlink "/opt/admin-tools/actual/bin/brew")
        if [ -x "$target" ]; then
            echo "$target"
            return
        fi
    fi
    
    # Otherwise search for brew in common locations
    local brew_locations=(
        "/opt/homebrew/bin/brew"
        "/usr/local/bin/brew"
        "/usr/local/Homebrew/bin/brew"
        "/home/linuxbrew/.linuxbrew/bin/brew"
    )
    
    for location in "${brew_locations[@]}"; do
        if [ -x "$location" ]; then
            echo "$location"
            return
        fi
    done
    
    # Fallback to which
    which brew 2>/dev/null || echo ""
}

ACTUAL_BREW=$(find_actual_brew)

if [ -z "$ACTUAL_BREW" ]; then
    echo "❌ Error: Homebrew not found"
    exit 1
fi

# Check if running as Guest
if [[ "$USER" == "Guest" ]]; then
    # Block dangerous commands
    case "$1" in
        install|uninstall|upgrade|update|tap|untap|link|unlink|pin|unpin)
            echo "❌ Error: System-wide modifications are not allowed for Guest users"
            echo "   Command '$1' has been blocked for security reasons"
            exit 1
            ;;
        reinstall|remove|rm|cleanup)
            echo "❌ Error: System-wide modifications are not allowed for Guest users"
            echo "   Command '$1' has been blocked for security reasons"
            exit 1
            ;;
        *)
            # Allow safe read-only commands
            exec "$ACTUAL_BREW" "$@"
            ;;
    esac
else
    # Non-guest users get full access
    exec "$ACTUAL_BREW" "$@"
fi
EOF
        chmod 755 /opt/admin-tools/wrappers/brew
    fi
fi

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

# Step 8: Install LaunchAgent and guest setup scripts
echo ""
echo "🚀 Installing LaunchAgent and guest setup scripts..."
./scripts/setup/setup_guest_shell_init.sh

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
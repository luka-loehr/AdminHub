#!/bin/bash

# AdminHub Simplified - Guest Tools Manager
# This script manages development tools for Guest accounts on macOS

set -e

# Configuration
ADMIN_TOOLS_DIR="/opt/admin-tools"
GUEST_TOOLS_DIR="/Users/Guest/DevTools"
GUEST_BIN_DIR="$GUEST_TOOLS_DIR/bin"
TOOLS_TO_INSTALL=("python3" "git" "node" "npm" "pip3" "jq" "wget")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

check_admin() {
    if [[ $EUID -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Main functions
install_tools_admin() {
    echo "🔧 Installing development tools in admin space..."
    
    # Create admin tools directory (needs sudo)
    if ! check_admin; then
        log_error "Creating $ADMIN_TOOLS_DIR requires sudo privileges"
        echo "Please run: sudo $0 install-admin"
        exit 1
    fi
    
    mkdir -p "$ADMIN_TOOLS_DIR/bin"
    log_info "Created $ADMIN_TOOLS_DIR"
    
    # Now drop sudo for Homebrew operations
    echo "📦 Installing tools via Homebrew (running as regular user)..."
    
    # Check for Homebrew as regular user
    if ! sudo -u "$SUDO_USER" bash -c "command -v brew &> /dev/null"; then
        log_error "Homebrew not found!"
        echo "Please install Homebrew first:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    
    BREW_PATH=$(sudo -u "$SUDO_USER" bash -c "which brew")
    log_info "Found Homebrew at $BREW_PATH"
    
    # Install tools via Homebrew as regular user
    
    # Python
    if ! sudo -u "$SUDO_USER" bash -c "brew list python@3.12 &> /dev/null"; then
        echo "🐍 Installing Python 3..."
        sudo -u "$SUDO_USER" bash -c "brew install python@3.12"
    else
        log_info "Python 3 already installed"
    fi
    
    # Git
    if ! sudo -u "$SUDO_USER" bash -c "brew list git &> /dev/null"; then
        echo "📚 Installing Git..."
        sudo -u "$SUDO_USER" bash -c "brew install git"
    else
        log_info "Git already installed"
    fi
    
    # Node.js
    if ! sudo -u "$SUDO_USER" bash -c "brew list node &> /dev/null"; then
        echo "📗 Installing Node.js..."
        sudo -u "$SUDO_USER" bash -c "brew install node"
    else
        log_info "Node.js already installed"
    fi
    
    # jq (JSON processor)
    if ! sudo -u "$SUDO_USER" bash -c "brew list jq &> /dev/null"; then
        echo "🔧 Installing jq..."
        sudo -u "$SUDO_USER" bash -c "brew install jq"
    else
        log_info "jq already installed"
    fi
    
    # wget (download tool)
    if ! sudo -u "$SUDO_USER" bash -c "brew list wget &> /dev/null"; then
        echo "📥 Installing wget..."
        sudo -u "$SUDO_USER" bash -c "brew install wget"
    else
        log_info "wget already installed"
    fi
    
    # Get brew prefix
    BREW_PREFIX=$(sudo -u "$SUDO_USER" bash -c "brew --prefix")
    
    # Create symlinks in admin tools directory (with sudo)
    echo "🔗 Creating symlinks in $ADMIN_TOOLS_DIR/bin..."
    
    # Create symlinks for all tools
    ln -sf "$BREW_PREFIX/bin/python3" "$ADMIN_TOOLS_DIR/bin/python3"
    ln -sf "$BREW_PREFIX/bin/pip3" "$ADMIN_TOOLS_DIR/bin/pip3"
    ln -sf "$BREW_PREFIX/bin/git" "$ADMIN_TOOLS_DIR/bin/git"
    ln -sf "$BREW_PREFIX/bin/node" "$ADMIN_TOOLS_DIR/bin/node"
    ln -sf "$BREW_PREFIX/bin/npm" "$ADMIN_TOOLS_DIR/bin/npm"
    ln -sf "$BREW_PREFIX/bin/jq" "$ADMIN_TOOLS_DIR/bin/jq"
    ln -sf "$BREW_PREFIX/bin/wget" "$ADMIN_TOOLS_DIR/bin/wget"
    
    # Also copy the actual Python3 framework
    if [ -d "$BREW_PREFIX/opt/python@3.12/Frameworks" ]; then
        echo "📦 Copying Python framework..."
        cp -R "$BREW_PREFIX/opt/python@3.12/Frameworks" "$ADMIN_TOOLS_DIR/" 2>/dev/null || true
    fi
    
    log_info "Admin tools setup complete!"
    
    # Show installed tools
    echo -e "\n📋 Installed tools in $ADMIN_TOOLS_DIR/bin:"
    ls -la "$ADMIN_TOOLS_DIR/bin/"
}

setup_guest_tools() {
    # Check if we're running as Guest
    CURRENT_USER=$(whoami)
    
    # Only proceed if we're Guest or forcing
    if [[ "$CURRENT_USER" != "Guest" ]] && [[ "$1" != "--force" ]] && [[ "$1" != "--in-terminal" ]]; then
        # Silently exit - no need to log anything for non-Guest users
        exit 0
    fi
    
    # Clear screen for clean display in terminal
    if [[ "$1" == "--in-terminal" ]]; then
        sleep 1  # Give Terminal time to open
    fi
    
    echo "🚀 Setting up development tools for Guest account..."
    echo ""
    echo "👤 User: $CURRENT_USER"
    echo "📅 Date: $(date)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Create Guest tools directory
    if [[ "$CURRENT_USER" == "Guest" ]] || [[ "$1" == "--force" ]] || [[ "$1" == "--in-terminal" ]]; then
        mkdir -p "$GUEST_BIN_DIR"
        log_info "Created $GUEST_BIN_DIR"
        
        # Copy tools from admin directory
        echo "📦 Starting tool installation..."
        echo ""
        
        if [[ -d "$ADMIN_TOOLS_DIR/bin" ]]; then
            # Copy each tool individually with progress
            for tool in "${TOOLS_TO_INSTALL[@]}"; do
                echo -n "  Installing $tool... "
                if cp -R "$ADMIN_TOOLS_DIR/bin/$tool" "$GUEST_BIN_DIR/" 2>/dev/null; then
                    echo "✅"
                    sleep 0.2  # Visual effect
                else
                    echo "⚠️  (might already exist)"
                fi
            done
            echo ""
            log_info "All tools copied to Guest directory"
        else
            log_error "Admin tools directory not found!"
            log_error "Please run: sudo $0 install-admin"
            exit 1
        fi
        
        # Update PATH in Guest's shell profile
        PROFILE_FILE="/Users/Guest/.zprofile"
        PATH_LINE='export PATH="'$GUEST_BIN_DIR':$PATH"'
        
        if ! grep -q "$GUEST_BIN_DIR" "$PROFILE_FILE" 2>/dev/null; then
            echo "$PATH_LINE" >> "$PROFILE_FILE"
            log_info "Updated PATH in $PROFILE_FILE"
        else
            log_info "PATH already configured"
        fi
        
        # Make tools executable
        chmod +x "$GUEST_BIN_DIR/"* 2>/dev/null || true
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        log_info "Guest tools setup complete!"
        echo ""
        echo "📋 Available Development Tools:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Show installed tools with icons and descriptions
        echo "  🐍 Python 3    $(python3 --version 2>/dev/null || echo 'Not found')"
        echo "  📦 pip3        Package manager for Python"
        echo "  📚 Git         $(git --version 2>/dev/null || echo 'Not found')"
        echo "  📗 Node.js     $(node --version 2>/dev/null || echo 'Not found')"
        echo "  📦 npm         $(npm --version 2>/dev/null || echo 'Not found')"
        echo "  🔧 jq          Command-line JSON processor"
        echo "  📥 wget        $(wget --version 2>/dev/null | head -1 || echo 'Not found')"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "✨ All tools are ready to use!"
        echo "💡 Tools are located in: $GUEST_BIN_DIR"
        echo "🔒 Zero-persistence: Everything will be removed on logout"
        echo ""
        echo "Happy coding! 🚀"
        echo ""
        
        # If in terminal, keep it open
        if [[ "$1" == "--in-terminal" ]]; then
            echo "Press any key to start using the terminal..."
            read -n 1 -s
            clear
        fi
    else
        echo "To actually copy files, run as Guest user or use --force flag"
    fi
}

cleanup_guest_tools() {
    echo "🧹 Cleaning up Guest tools..."
    
    if [[ -d "$GUEST_TOOLS_DIR" ]]; then
        rm -rf "$GUEST_TOOLS_DIR"
        log_info "Removed $GUEST_TOOLS_DIR"
    else
        log_warning "Guest tools directory not found"
    fi
    
    # Remove PATH entry from profile
    if [[ -f "/Users/Guest/.zprofile" ]]; then
        sed -i '' "/$GUEST_BIN_DIR/d" "/Users/Guest/.zprofile" 2>/dev/null || true
        log_info "Cleaned up .zprofile"
    fi
}

create_launch_agent() {
    echo "🚀 Creating LaunchAgent for automatic Guest setup..."
    
    if ! check_admin; then
        log_error "Creating LaunchAgent requires sudo privileges"
        echo "Please run: sudo $0 create-agent"
        exit 1
    fi
    
    PLIST_PATH="/Library/LaunchAgents/com.adminhub.guesttools.plist"
    SCRIPT_PATH="/usr/local/bin/guest_tools_setup.sh"
    
    # Copy this script to a system location
    cp "$0" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    log_info "Copied script to $SCRIPT_PATH"
    
    # Create LaunchAgent plist
    cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.adminhub.guesttools</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
        <string>setup</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/guesttools.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/guesttools.error.log</string>
</dict>
</plist>
EOF
    
    chmod 644 "$PLIST_PATH"
    log_info "Created LaunchAgent at $PLIST_PATH"
    
    # Load the agent
    launchctl load "$PLIST_PATH" 2>/dev/null || true
    log_info "LaunchAgent loaded"
    
    echo -e "\n📋 LaunchAgent will automatically:"
    echo "  - Run when any user logs in"
    echo "  - Set up tools if user is 'Guest'"
    echo "  - Log output to /tmp/guesttools.log"
}

test_setup() {
    echo "🧪 Testing Guest Tools Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo -e "\n👤 Current user: $(whoami)"
    
    echo -e "\n📍 System locations:"
    echo "  Admin tools: $ADMIN_TOOLS_DIR"
    echo "  Guest tools: $GUEST_TOOLS_DIR"
    
    echo -e "\n🔍 Checking admin tools:"
    if [[ -d "$ADMIN_TOOLS_DIR/bin" ]]; then
        log_info "Admin tools directory exists"
        ls -la "$ADMIN_TOOLS_DIR/bin/" 2>/dev/null | grep -E "python3|git|node|npm" || log_warning "No tools found"
    else
        log_error "Admin tools directory not found"
    fi
    
    echo -e "\n🔍 Checking Homebrew tools:"
    for tool in python3 git node npm; do
        if command -v $tool &> /dev/null; then
            log_info "$tool: $(which $tool)"
        else
            log_error "$tool: not found"
        fi
    done
    
    echo -e "\n🔍 Checking LaunchAgent:"
    if [[ -f "/Library/LaunchAgents/com.adminhub.guesttools.plist" ]]; then
        log_info "LaunchAgent installed"
    else
        log_warning "LaunchAgent not installed"
    fi
}

# Main script logic
case "${1:-help}" in
    install-admin)
        install_tools_admin
        ;;
    setup)
        setup_guest_tools "$2"
        ;;
    cleanup)
        cleanup_guest_tools
        ;;
    create-agent)
        create_launch_agent
        ;;
    test)
        test_setup
        ;;
    *)
        echo "AdminHub Guest Tools Manager"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  install-admin  - Install tools in admin space (requires sudo)"
        echo "  setup         - Copy tools to Guest account"
        echo "  cleanup       - Remove tools from Guest account"
        echo "  create-agent  - Create LaunchAgent for auto-setup (requires sudo)"
        echo "  test          - Test current setup"
        echo ""
        echo "Quick start:"
        echo "  1. sudo $0 install-admin"
        echo "  2. sudo $0 create-agent"
        echo "  3. $0 test"
        ;;
esac 
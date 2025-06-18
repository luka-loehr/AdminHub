#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Guest Tools Manager
# Dieses Script verwaltet die Entwicklertools für den Guest-Account

ADMIN_TOOLS_DIR="/opt/admin-tools"
GUEST_TOOLS_DIR="/Users/Guest/tools"
LAUNCHAGENT_PLIST="/Library/LaunchAgents/com.adminhub.guesttools.plist"
TERMINAL_PLIST="/Library/LaunchAgents/com.adminhub.guestterminal.plist"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${GREEN}AdminHub Guest Tools Manager${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# If no arguments provided, run install-admin by default
if [ $# -eq 0 ]; then
    COMMAND="install-admin"
else
    COMMAND=$1
fi

case $COMMAND in
    install-admin)
        print_header
        echo "📦 Installing developer tools in admin space..."
        
        # Check if running as root
        if [ "$EUID" -ne 0 ]; then 
            echo -e "${RED}❌ Please run with sudo: sudo $0 install-admin${NC}"
            exit 1
        fi
        
        # Check for Homebrew
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}❌ Homebrew not found. Please install Homebrew first.${NC}"
            echo "Visit: https://brew.sh"
            exit 1
        fi
        
        # Create admin tools directory
        echo "📁 Creating $ADMIN_TOOLS_DIR directory..."
        mkdir -p "$ADMIN_TOOLS_DIR/bin"
        
        # Install tools via Homebrew if not already installed
        echo ""
        echo "🔧 Installing tools via Homebrew..."
        
        # Python3 (usually pre-installed on macOS)
        if ! command -v python3 &> /dev/null; then
            echo "  Installing Python3..."
            brew install python3
        else
            echo "  ✅ Python3 already installed"
        fi
        
        # Git
        if ! brew list git &> /dev/null 2>&1; then
            echo "  Installing Git..."
            brew install git
        else
            echo "  ✅ Git already installed"
        fi
        
        # Node and npm
        if ! brew list node &> /dev/null 2>&1; then
            echo "  Installing Node.js and npm..."
            brew install node
        else
            echo "  ✅ Node.js already installed"
        fi
        
        # jq
        if ! brew list jq &> /dev/null 2>&1; then
            echo "  Installing jq..."
            brew install jq
        else
            echo "  ✅ jq already installed"
        fi
        
        # wget
        if ! brew list wget &> /dev/null 2>&1; then
            echo "  Installing wget..."
            brew install wget
        else
            echo "  ✅ wget already installed"
        fi
        
        # Create symlinks in admin tools directory
        echo ""
        echo "🔗 Creating symlinks in $ADMIN_TOOLS_DIR/bin..."
        
        # Function to create symlink safely
        create_symlink() {
            local source=$1
            local target=$2
            
            if [ -e "$source" ]; then
                ln -sf "$source" "$target"
                echo "  ✅ Linked $(basename $target)"
            else
                echo "  ⚠️  Source not found: $source"
            fi
        }
        
        # Find the correct paths and create symlinks
        if command -v python3 &> /dev/null; then
            create_symlink "$(which python3)" "$ADMIN_TOOLS_DIR/bin/python3"
            # Also link pip3 if it exists
            if command -v pip3 &> /dev/null; then
                create_symlink "$(which pip3)" "$ADMIN_TOOLS_DIR/bin/pip3"
            fi
        fi
        
        if command -v git &> /dev/null; then
            create_symlink "$(which git)" "$ADMIN_TOOLS_DIR/bin/git"
        fi
        
        # Node tools might be in different locations
        for tool in node npm npx jq wget; do
            # First check homebrew location
            if [ -e "/opt/homebrew/bin/$tool" ]; then
                create_symlink "/opt/homebrew/bin/$tool" "$ADMIN_TOOLS_DIR/bin/$tool"
            elif [ -e "/usr/local/bin/$tool" ]; then
                create_symlink "/usr/local/bin/$tool" "$ADMIN_TOOLS_DIR/bin/$tool"
            elif command -v $tool &> /dev/null; then
                create_symlink "$(which $tool)" "$ADMIN_TOOLS_DIR/bin/$tool"
            fi
        done
        
        # Set permissions
        echo ""
        echo "🔐 Setting permissions..."
        chmod -R 755 "$ADMIN_TOOLS_DIR"
        
        # Create simple setup script
        echo ""
        echo "📝 Installing Terminal setup script..."
        
        # First copy the simple guest setup script
        if [ -f "simple_guest_setup.sh" ]; then
            cp simple_guest_setup.sh /usr/local/bin/
            chmod 755 /usr/local/bin/simple_guest_setup.sh
            echo "  ✅ Installed simple_guest_setup.sh"
        fi
        
        # Then copy the terminal opener
        if [ -f "open_guest_terminal.sh" ]; then
            cp open_guest_terminal.sh /usr/local/bin/open_guest_terminal
            chmod 755 /usr/local/bin/open_guest_terminal
            echo "  ✅ Installed open_guest_terminal"
        fi
        
        echo ""
        echo -e "${GREEN}✅ Admin tools installation complete!${NC}"
        echo ""
        echo "Tools installed in: $ADMIN_TOOLS_DIR/bin/"
        echo "Next: Run 'sudo $0 create-agent' to set up auto-launch"
        ;;
        
    setup)
        print_header
        echo "🚀 Setting up tools for current user..."
        
        # Only proceed if we're the Guest user
        if [ "$USER" != "Guest" ]; then
            echo -e "${YELLOW}⚠️  This command is meant for the Guest user.${NC}"
            echo "Current user: $USER"
            echo ""
            echo "For admin setup, use: sudo $0 install-admin"
            exit 1
        fi
        
        # Check if admin tools exist
        if [ ! -d "$ADMIN_TOOLS_DIR/bin" ]; then
            echo -e "${RED}❌ Admin tools not found at $ADMIN_TOOLS_DIR${NC}"
            echo "Please run: sudo $0 install-admin"
            exit 1
        fi
        
        # Create Guest tools directory
        echo "📁 Creating Guest tools directory..."
        mkdir -p "$GUEST_TOOLS_DIR/bin"
        
        # Copy tools to Guest directory
        echo "📋 Copying tools to Guest directory..."
        cp -R "$ADMIN_TOOLS_DIR/bin/"* "$GUEST_TOOLS_DIR/bin/" 2>/dev/null || true
        
        # Update shell profile
        echo "🔧 Updating shell profile..."
        PROFILE="$HOME/.zprofile"
        
        # Add to PATH if not already there
        if ! grep -q "$GUEST_TOOLS_DIR/bin" "$PROFILE" 2>/dev/null; then
            echo "" >> "$PROFILE"
            echo "# AdminHub Guest Tools" >> "$PROFILE"
            echo "export PATH=\"$GUEST_TOOLS_DIR/bin:\$PATH\"" >> "$PROFILE"
        fi
        
        echo ""
        echo -e "${GREEN}✅ Guest tools setup complete!${NC}"
        echo ""
        echo "Tools available at: $GUEST_TOOLS_DIR/bin/"
        echo "Restart Terminal or run: source ~/.zprofile"
        ;;
        
    cleanup)
        print_header
        echo "🧹 Cleaning up Guest tools..."
        
        if [ "$USER" = "Guest" ] && [ -d "$GUEST_TOOLS_DIR" ]; then
            rm -rf "$GUEST_TOOLS_DIR"
            echo "✅ Removed $GUEST_TOOLS_DIR"
            
            # Remove from profile
            if [ -f "$HOME/.zprofile" ]; then
                sed -i '' '/# AdminHub Guest Tools/,+1d' "$HOME/.zprofile" 2>/dev/null || true
                echo "✅ Cleaned .zprofile"
            fi
        else
            echo "No Guest tools found to clean."
        fi
        ;;
        
    create-agent)
        print_header
        echo "🤖 Creating LaunchAgent for Terminal auto-open..."
        
        # Check if running as root
        if [ "$EUID" -ne 0 ]; then 
            echo -e "${RED}❌ Please run with sudo: sudo $0 create-agent${NC}"
            exit 1
        fi
        
        # Create LaunchAgent for terminal
        cat > "$TERMINAL_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.adminhub.guestterminal</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/open_guest_terminal</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>UserName</key>
    <string>Guest</string>
    <key>StandardOutPath</key>
    <string>/tmp/adminhub-terminal.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/adminhub-terminal.err</string>
</dict>
</plist>
EOF
        
        # Set permissions
        chmod 644 "$TERMINAL_PLIST"
        
        # Load the agent
        launchctl load "$TERMINAL_PLIST" 2>/dev/null || true
        
        echo ""
        echo -e "${GREEN}✅ LaunchAgent created successfully!${NC}"
        echo ""
        echo "Terminal will now open automatically when Guest logs in."
        ;;
        
    test)
        print_header
        echo "🧪 Testing current setup..."
        echo ""
        
        # Test admin tools
        echo "Admin tools directory:"
        if [ -d "$ADMIN_TOOLS_DIR/bin" ]; then
            echo "  ✅ $ADMIN_TOOLS_DIR/bin exists"
            echo "  Contents: $(ls -1 $ADMIN_TOOLS_DIR/bin 2>/dev/null | tr '\n' ' ')"
        else
            echo "  ❌ $ADMIN_TOOLS_DIR/bin not found"
        fi
        
        echo ""
        echo "Testing tool availability:"
        
        # Function to test tool
        test_tool() {
            local tool=$1
            local version_flag=$2
            
            if [ -e "$ADMIN_TOOLS_DIR/bin/$tool" ]; then
                echo -n "  ✅ $tool: "
                if [ -x "$ADMIN_TOOLS_DIR/bin/$tool" ]; then
                    $ADMIN_TOOLS_DIR/bin/$tool $version_flag 2>&1 | head -1 || echo "installed"
                else
                    echo "not executable"
                fi
            else
                echo "  ❌ $tool: not found in admin tools"
            fi
        }
        
        test_tool "python3" "--version"
        test_tool "git" "--version"
        test_tool "node" "--version"
        test_tool "npm" "--version"
        test_tool "jq" "--version"
        test_tool "wget" "--version"
        
        echo ""
        echo "LaunchAgent status:"
        if [ -f "$TERMINAL_PLIST" ]; then
            echo "  ✅ Terminal LaunchAgent installed"
            if launchctl list | grep -q "com.adminhub.guestterminal"; then
                echo "  ✅ Terminal LaunchAgent loaded"
            else
                echo "  ⚠️  Terminal LaunchAgent not loaded"
            fi
        else
            echo "  ❌ Terminal LaunchAgent not installed"
        fi
        
        echo ""
        echo "Current user: $USER"
        if [ "$USER" = "Guest" ]; then
            echo "PATH includes admin tools: "
            if echo $PATH | grep -q "$ADMIN_TOOLS_DIR/bin"; then
                echo "  ✅ Yes"
            else
                echo "  ❌ No - run 'source ~/.zprofile' or restart Terminal"
            fi
        fi
        ;;
        
    *)
        print_header
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
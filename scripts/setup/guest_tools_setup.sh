#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Guest Tools Manager
# This script manages the development tools for the Guest account

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
    echo "© 2025 Luka Löhr"
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
        echo "📦 Installing development tools in admin area..."
        
        # Check if running as root
        if [ "$EUID" -ne 0 ]; then 
            echo -e "${RED}❌ Please run with sudo: sudo $0 install-admin${NC}"
            exit 1
        fi
        
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}❌ Homebrew not found. Please install Homebrew first.${NC}"
            echo "Visit: https://brew.sh"
            exit 1
        fi
        
        # Create admin tools directory
        echo "📁 Creating $ADMIN_TOOLS_DIR directory..."
        mkdir -p "$ADMIN_TOOLS_DIR/bin"
        
        # Check installed tools (Homebrew must not run as root!)
        echo ""
        echo "🔧 Checking installed tools..."
        
        # Function to check if tool is installed
        check_tool() {
            local tool=$1
            local display_name=$2
            
            if command -v $tool &> /dev/null; then
                echo "  ✅ $display_name already installed"
                return 0
            else
                echo "  ⚠️  $display_name not found"
                return 1
            fi
        }
        
        # Check all required tools
        MISSING_TOOLS=false
        
        check_tool "brew" "Homebrew" || MISSING_TOOLS=true
        check_tool "python3" "Python3" || MISSING_TOOLS=true
        check_tool "python" "Python" || MISSING_TOOLS=true
        check_tool "pip3" "pip3" || MISSING_TOOLS=true
        check_tool "pip" "pip" || MISSING_TOOLS=true
        check_tool "git" "Git" || MISSING_TOOLS=true
        
        # If tools are missing, ask if they should be installed
        if [ "$MISSING_TOOLS" = true ]; then
            echo ""
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}⚠️  WARNING: Some tools are missing!${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "To provide students with the desired tools on the"
            echo "Guest account, these tools must be installed."
            echo ""
            echo -e "${GREEN}Should I install the missing tools now?${NC}"
            echo ""
            echo -n "Answer (y/n): "
            read -r response
            
            if [[ ! "$response" =~ ^[yY]$ ]]; then
                echo ""
                echo -e "${RED}❌ Setup cancelled.${NC}"
                echo "The tools must be installed for AdminHub."
                exit 1
            fi
            
            echo ""
            echo "🚀 Installing missing tools..."
            echo ""
            
            # Determine the real user (not root)
            if [ -n "$SUDO_USER" ]; then
                ORIGINAL_USER="$SUDO_USER"
            else
                ORIGINAL_USER=$(who am i | awk '{print $1}')
            fi
            
            # If still root, try a different approach
            if [ "$ORIGINAL_USER" = "root" ] || [ -z "$ORIGINAL_USER" ]; then
                # Get user from the terminal's home directory
                ORIGINAL_USER=$(stat -f "%Su" /dev/console)
            fi
            
            echo "🔄 Using user '$ORIGINAL_USER' for installation..."
            echo ""
            
            # Create temporary script for installation
            INSTALL_SCRIPT="/tmp/adminhub_install_tools.sh"
            cat > "$INSTALL_SCRIPT" << 'INSTALLEOF'
#!/bin/bash
echo "📦 Installing tools via Homebrew..."

# Array of tools to install
TOOLS_TO_INSTALL=""

# Check which tools are missing and add them to the list
command -v git &> /dev/null || TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL git"
command -v python &> /dev/null || TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL python"

if [ -n "$TOOLS_TO_INSTALL" ]; then
    echo "Installing: $TOOLS_TO_INSTALL"
    brew install $TOOLS_TO_INSTALL
    echo ""
    echo "✅ Installation completed!"
else
    echo "✅ All tools already installed!"
fi
INSTALLEOF
            
            chmod +x "$INSTALL_SCRIPT"
            
            # Run installation as normal user
            if [ "$ORIGINAL_USER" = "root" ] || [ -z "$ORIGINAL_USER" ]; then
                echo -e "${RED}❌ Could not determine username.${NC}"
                echo "Please run the installation manually:"
                echo "  brew install git python"
                MISSING_TOOLS=false
            else
                echo "Running installation..."
                su - "$ORIGINAL_USER" -c "$INSTALL_SCRIPT"
            fi
            
            # Cleanup
            rm -f "$INSTALL_SCRIPT"
            
            echo ""
            echo -e "${GREEN}✅ Tools have been installed!${NC}"
            echo ""
            echo "Continuing with setup..."
            sleep 2
        fi
        
        # Create symlinks in admin tools directory
        echo ""
        echo "🔗 Creating symlinks in $ADMIN_TOOLS_DIR/bin..."
        
        # Function to safely create symlinks
        create_symlink() {
            local source=$1
            local target=$2
            
            if [ -e "$source" ]; then
                ln -sf "$source" "$target"
                echo "  ✅ Linked: $(basename $target)"
            else
                echo "  ⚠️  Source not found: $source"
            fi
        }
        
        # Create symlink for brew
        if command -v brew &> /dev/null; then
            create_symlink "$(which brew)" "$ADMIN_TOOLS_DIR/bin/brew"
        fi
        
        # Find the correct paths and create symlinks
        if command -v python3 &> /dev/null; then
            create_symlink "$(which python3)" "$ADMIN_TOOLS_DIR/bin/python3"
            # Also link pip3 if it exists
            if command -v pip3 &> /dev/null; then
                create_symlink "$(which pip3)" "$ADMIN_TOOLS_DIR/bin/pip3"
            fi
        fi
        
        # Link python and pip (not just python3)
        # Check for python in libexec first (Homebrew's unversioned symlinks)
        if [ -e "/opt/homebrew/opt/python@3.13/libexec/bin/python" ]; then
            create_symlink "/opt/homebrew/opt/python@3.13/libexec/bin/python" "$ADMIN_TOOLS_DIR/bin/python"
            create_symlink "/opt/homebrew/opt/python@3.13/libexec/bin/pip" "$ADMIN_TOOLS_DIR/bin/pip"
        elif [ -e "/opt/homebrew/opt/python@3.12/libexec/bin/python" ]; then
            create_symlink "/opt/homebrew/opt/python@3.12/libexec/bin/python" "$ADMIN_TOOLS_DIR/bin/python"
            create_symlink "/opt/homebrew/opt/python@3.12/libexec/bin/pip" "$ADMIN_TOOLS_DIR/bin/pip"
        elif command -v python &> /dev/null; then
            create_symlink "$(which python)" "$ADMIN_TOOLS_DIR/bin/python"
            if command -v pip &> /dev/null; then
                create_symlink "$(which pip)" "$ADMIN_TOOLS_DIR/bin/pip"
            fi
        fi
        
        if command -v git &> /dev/null; then
            create_symlink "$(which git)" "$ADMIN_TOOLS_DIR/bin/git"
        fi
        
        # Set permissions
        echo ""
        echo "🔐 Setting permissions..."
        chmod -R 755 "$ADMIN_TOOLS_DIR"
        
        # Install setup scripts
        echo ""
        echo "📝 Installing terminal setup scripts..."
        
        # Copy required scripts if available
        if [ -f "simple_guest_setup.sh" ]; then
            cp simple_guest_setup.sh /usr/local/bin/
            chmod 755 /usr/local/bin/simple_guest_setup.sh
            echo "  ✅ simple_guest_setup.sh installed"
        fi
        
        # Copy terminal opener
        if [ -f "open_guest_terminal.sh" ]; then
            cp open_guest_terminal.sh /usr/local/bin/open_guest_terminal
            chmod 755 /usr/local/bin/open_guest_terminal
            echo "  ✅ open_guest_terminal installed"
        fi
        
        echo ""
        echo -e "${GREEN}✅ Admin tools installation completed!${NC}"
        echo ""
        echo "Tools installed in: $ADMIN_TOOLS_DIR/bin/"
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
        
        test_tool "brew" "--version"
        test_tool "python3" "--version"
        test_tool "python" "--version"
        test_tool "pip3" "--version"
        test_tool "pip" "--version"
        test_tool "git" "--version"
        
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
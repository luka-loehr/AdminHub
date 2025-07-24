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
        echo "📦 Installing development tools..."
        
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
        mkdir -p "$ADMIN_TOOLS_DIR/bin"
        
        # Check installed tools (Homebrew must not run as root!)
        
        # Function to check if tool is installed
        check_tool() {
            local tool=$1
            local display_name=$2
            
            # First check if it's in PATH
            if command -v $tool &> /dev/null; then
                return 0
            fi
            
            # Check common Homebrew locations
            if [ -e "/opt/homebrew/bin/$tool" ] || [ -e "/usr/local/bin/$tool" ]; then
                return 0
            fi
            
            # Special case for python/pip - check libexec directories
            if [[ "$tool" == "python" ]] || [[ "$tool" == "pip" ]]; then
                if [ -e "/opt/homebrew/opt/python@3.13/libexec/bin/$tool" ] || \
                   [ -e "/opt/homebrew/opt/python@3.12/libexec/bin/$tool" ] || \
                   [ -e "/opt/homebrew/opt/python@3.11/libexec/bin/$tool" ]; then
                    return 0
                fi
            fi
            
            # Also check our admin tools directory
            if [ -e "$ADMIN_TOOLS_DIR/bin/$tool" ]; then
                return 0
            fi
            
            return 1
        }
        
        # Check all required tools
        MISSING_TOOLS=false
        MISSING_LIST=""
        
        check_tool "brew" "Homebrew" || { MISSING_TOOLS=true; MISSING_LIST="$MISSING_LIST brew"; }
        check_tool "python3" "Python3" || { MISSING_TOOLS=true; MISSING_LIST="$MISSING_LIST python3"; }
        check_tool "python" "Python" || { MISSING_TOOLS=true; MISSING_LIST="$MISSING_LIST python"; }
        check_tool "pip3" "pip3" || { MISSING_TOOLS=true; MISSING_LIST="$MISSING_LIST pip3"; }
        check_tool "pip" "pip" || { MISSING_TOOLS=true; MISSING_LIST="$MISSING_LIST pip"; }
        check_tool "git" "Git" || { MISSING_TOOLS=true; MISSING_LIST="$MISSING_LIST git"; }
        
        # If tools are missing, ask if they should be installed
        if [ "$MISSING_TOOLS" = true ]; then
            echo ""
            echo -e "${YELLOW}⚠️  Some tools need to be configured:${NC}"
            echo "Missing:$MISSING_LIST"
            echo -n "Configure now? (y/n): "
            read -r response
            
            if [[ ! "$response" =~ ^[yY]$ ]]; then
                echo ""
                echo -e "${RED}❌ Setup cancelled.${NC}"
                echo "The tools must be installed for AdminHub."
                exit 1
            fi
            
            
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
            
            
            # Create temporary script for installation
            INSTALL_SCRIPT="/tmp/adminhub_install_tools.sh"
            cat > "$INSTALL_SCRIPT" << 'INSTALLEOF'
#!/bin/bash
echo "📦 Installing tools via Homebrew..."

# Array of tools to install
TOOLS_TO_INSTALL=""

# Check which tools are missing and add them to the list
if ! command -v git &> /dev/null && ! [ -e "/opt/homebrew/bin/git" ] && ! [ -e "/usr/local/bin/git" ]; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL git"
fi

# For Python, we need to check if python3 is installed but python/pip symlinks are missing
PYTHON_INSTALLED=false
PYTHON_VERSION=""

# Check for existing Python installations
for version in 3.13 3.12 3.11; do
    if [ -e "/opt/homebrew/opt/python@$version/libexec/bin/python" ]; then
        PYTHON_INSTALLED=true
        PYTHON_VERSION=$version
        break
    fi
done

# Also check if python3 exists
if command -v python3 &> /dev/null || [ -e "/opt/homebrew/bin/python3" ]; then
    PYTHON_INSTALLED=true
fi

# Only install Python if it's not already installed
if [ "$PYTHON_INSTALLED" = false ]; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL python"
fi

if [ -n "$TOOLS_TO_INSTALL" ]; then
    echo "Installing: $TOOLS_TO_INSTALL"
    brew install $TOOLS_TO_INSTALL
    echo ""
    echo "✅ Installation completed!"
else
    echo "✅ All core tools already installed!"
    if [ "$PYTHON_INSTALLED" = true ]; then
        echo "   Python is installed - will create symlinks for python/pip commands"
    fi
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
            
        fi
        
        # Create symlinks in admin tools directory
        
        # Function to safely create symlinks
        create_symlink() {
            local source=$1
            local target=$2
            
            if [ -e "$source" ]; then
                ln -sf "$source" "$target" 2>/dev/null
                echo "   ✓ Created symlink: $(basename "$target") -> $source"
            fi
        }
        
        echo ""
        echo "🔗 Creating tool symlinks..."
        
        # Detect Homebrew location - handle various installation layouts
        BREW_PREFIX=""
        BREW_BIN=""
        
        # Check standard locations first
        if [ -x "/opt/homebrew/bin/brew" ]; then
            BREW_PREFIX="/opt/homebrew"
            BREW_BIN="/opt/homebrew/bin/brew"
        elif [ -x "/usr/local/bin/brew" ]; then
            # Check if this is a wrapper script or actual brew
            if grep -q "HOMEBREW_PREFIX" "/usr/local/bin/brew" 2>/dev/null; then
                # It's the wrapper, actual Homebrew might be elsewhere
                BREW_PREFIX="/usr/local"
                BREW_BIN="/usr/local/bin/brew"
                
                # Check for Homebrew in non-standard location
                if [ -d "/usr/local/Homebrew" ]; then
                    BREW_PREFIX="/usr/local/Homebrew"
                fi
            else
                BREW_PREFIX="/usr/local"
                BREW_BIN="/usr/local/bin/brew"
            fi
        elif [ -x "/usr/local/Homebrew/bin/brew" ]; then
            # Non-standard location
            BREW_PREFIX="/usr/local/Homebrew"
            BREW_BIN="/usr/local/Homebrew/bin/brew"
        fi
        
        # Create symlink for brew
        if [ -n "$BREW_BIN" ]; then
            create_symlink "$BREW_BIN" "$ADMIN_TOOLS_DIR/bin/brew"
        else
            echo "   ⚠️  Could not find brew executable"
        fi
        
        # Find the correct paths and create symlinks
        if command -v python3 &> /dev/null; then
            create_symlink "$(which python3)" "$ADMIN_TOOLS_DIR/bin/python3"
            # Also link pip3 if it exists
            if command -v pip3 &> /dev/null; then
                create_symlink "$(which pip3)" "$ADMIN_TOOLS_DIR/bin/pip3"
            fi
        fi
        
        # Link python and pip (not just python3) - check multiple Python versions
        PYTHON_LINKED=false
        for VERSION in 3.13 3.12 3.11 3.10; do
            # Check both common Homebrew locations
            for PREFIX in "/opt/homebrew" "/usr/local"; do
                PYTHON_LIBEXEC="$PREFIX/opt/python@$VERSION/libexec/bin"
                if [ -e "$PYTHON_LIBEXEC/python" ]; then
                    create_symlink "$PYTHON_LIBEXEC/python" "$ADMIN_TOOLS_DIR/bin/python"
                    create_symlink "$PYTHON_LIBEXEC/pip" "$ADMIN_TOOLS_DIR/bin/pip"
                    PYTHON_LINKED=true
                    break 2
                fi
            done
        done
        
        # Fallback if no libexec Python found
        if [ "$PYTHON_LINKED" = false ]; then
            if command -v python &> /dev/null; then
                create_symlink "$(which python)" "$ADMIN_TOOLS_DIR/bin/python"
                if command -v pip &> /dev/null; then
                    create_symlink "$(which pip)" "$ADMIN_TOOLS_DIR/bin/pip"
                fi
            else
                # Last resort: link python3 to python
                if [ -e "$ADMIN_TOOLS_DIR/bin/python3" ]; then
                    create_symlink "$ADMIN_TOOLS_DIR/bin/python3" "$ADMIN_TOOLS_DIR/bin/python"
                fi
                if [ -e "$ADMIN_TOOLS_DIR/bin/pip3" ]; then
                    create_symlink "$ADMIN_TOOLS_DIR/bin/pip3" "$ADMIN_TOOLS_DIR/bin/pip"
                fi
            fi
        fi
        
        if command -v git &> /dev/null; then
            create_symlink "$(which git)" "$ADMIN_TOOLS_DIR/bin/git"
        fi
        
        # Verify symlinks
        echo ""
        echo "🔍 Verifying symlinks..."
        for tool in brew python python3 pip pip3 git; do
            if [ -L "$ADMIN_TOOLS_DIR/bin/$tool" ] && [ -e "$ADMIN_TOOLS_DIR/bin/$tool" ]; then
                echo "   ✅ $tool: OK"
            elif [ -e "$ADMIN_TOOLS_DIR/bin/$tool" ]; then
                echo "   ⚠️  $tool: exists but not a symlink"
            else
                echo "   ❌ $tool: missing"
            fi
        done
        
        # Set permissions
        chmod -R 755 "$ADMIN_TOOLS_DIR"
        
        # Install setup scripts
        
        # Copy required scripts if available
        if [ -f "simple_guest_setup.sh" ]; then
            cp simple_guest_setup.sh /usr/local/bin/
            chmod 755 /usr/local/bin/simple_guest_setup.sh
        fi
        
        # Copy terminal opener
        if [ -f "open_guest_terminal.sh" ]; then
            cp open_guest_terminal.sh /usr/local/bin/open_guest_terminal
            chmod 755 /usr/local/bin/open_guest_terminal
        fi
        
        echo -e "${GREEN}✅ Tools installed successfully!${NC}"
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
        
        
    *)
        print_header
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  install-admin  - Install tools in admin space (requires sudo)"
        echo "  setup         - Copy tools to Guest account"
        echo "  cleanup       - Remove tools from Guest account"
        echo "  create-agent  - Create LaunchAgent for auto-setup (requires sudo)"
        echo ""
        echo "Quick start:"
        echo "  1. sudo $0 install-admin"
        echo "  2. sudo $0 create-agent"
        ;;
esac 
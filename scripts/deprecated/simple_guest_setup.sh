#!/bin/bash

# AdminHub Guest Tools - Ready to use!
clear
echo "🚀 AdminHub Guest Tools Setup"
echo "=============================="
echo ""
echo "👤 User: $(whoami)"
echo "📅 $(date)"
echo ""

# Start a background process that will close THIS terminal window after 10 seconds
(
    sleep 10
    # Get the TTY of this terminal
    CURRENT_TTY=$(tty)
    # Use AppleScript to close the terminal window with this TTY
    osascript -e "tell application \"Terminal\"
        set windowList to windows
        repeat with w in windowList
            set tabList to tabs of w
            repeat with t in tabList
                if (tty of t) is \"$CURRENT_TTY\" then
                    close w
                    exit repeat
                end if
            end repeat
        end repeat
    end tell" 2>/dev/null
) &

echo "⏰ This window will auto-close in 10 seconds..."
echo ""

# Set PATH for this session
export PATH="/opt/admin-tools/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Also ensure it's in .zprofile for future sessions
if ! grep -q "AdminHub Tools Path" ~/.zprofile 2>/dev/null; then
    cat >> ~/.zprofile << 'EOF'

# AdminHub Tools Path
export PATH="/opt/admin-tools/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
EOF
fi

echo "📝 Setting up environment..."
echo ""

# Create a script that will run in the new terminal
cat > /tmp/guest_tools_ready.sh << 'EOF'
#!/bin/bash
clear
echo "🚀 AdminHub Tools Ready!"
echo "========================"
echo ""
echo "📋 Installed tools:"
echo ""

# Check tools with nice formatting
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

if command -v jq &> /dev/null; then
    echo "  ✅ jq $(jq --version 2>/dev/null || echo 'installed')"
else
    echo "  ❌ jq not found"
fi

if command -v wget &> /dev/null; then
    echo "  ✅ wget installed"
else
    echo "  ❌ wget not found"
fi

echo ""
echo "🎉 All tools are ready to use!"
echo ""
echo "Try these commands:"
echo "  • python3 --version"
echo "  • git status"
echo "  • node --version"
echo ""
echo "💡 Zero-persistence: Everything clears on logout"
echo ""

# Clean up
rm -f /tmp/guest_tools_ready.sh
EOF

chmod +x /tmp/guest_tools_ready.sh

echo "🔄 Opening new Terminal with tools ready..."
echo ""

# Open new Terminal and run the ready script
osascript -e 'tell application "Terminal" to activate' -e 'tell application "Terminal" to do script "/tmp/guest_tools_ready.sh"'

echo "✅ New Terminal opened!"
echo ""
echo "🔄 This window will close automatically..."

# Keep the script running so the terminal doesn't show the prompt
while true; do
    sleep 1
done 
#!/bin/bash

# Silent setup script - runs in background without terminal
# This prepares everything and then opens Terminal when ready

# Set up environment in .zprofile
if ! grep -q "AdminHub Tools Path" /Users/Guest/.zprofile 2>/dev/null; then
    cat >> /Users/Guest/.zprofile << 'EOF'

# AdminHub Tools Path
export PATH="/opt/admin-tools/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
EOF
fi

# Create the ready script that will show in Terminal
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

# Wait a moment for system to be ready
sleep 2

# Now open Terminal with everything ready
osascript -e 'tell application "Terminal" to activate' -e 'tell application "Terminal" to do script "/tmp/guest_tools_ready.sh"' 
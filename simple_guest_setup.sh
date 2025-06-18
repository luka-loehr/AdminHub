#!/bin/bash

# Simple setup script for Guest that actually works
echo "🎯 AdminHub Guest Tools Setup"
echo "===================================="
echo ""
echo "👤 User: $(whoami)"
echo "📅 Date: $(date)"
echo ""

# Add paths to .zprofile (only if not already there)
echo "📝 Configuring environment..."
if ! grep -q "AdminHub Tools Path" ~/.zprofile 2>/dev/null; then
    cat >> ~/.zprofile << 'EOF'

# AdminHub Tools Path
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
EOF
fi

# Also set PATH for current session
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

echo "✅ Environment configured"
echo ""
echo "🔍 Checking available tools..."
echo ""

# Check what's actually available
echo "Development tools available:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Python - check multiple locations
if [ -x "/usr/bin/python3" ]; then
    echo "  🐍 python3    $(/usr/bin/python3 --version)"
elif [ -x "/opt/homebrew/bin/python3" ]; then
    echo "  🐍 python3    $(/opt/homebrew/bin/python3 --version)"
else
    echo "  ❌ python3    not found"
fi

# Git - check multiple locations
if [ -x "/usr/bin/git" ]; then
    echo "  📚 git        $(/usr/bin/git --version)"
elif [ -x "/opt/homebrew/bin/git" ]; then
    echo "  📚 git        $(/opt/homebrew/bin/git --version)"
else
    echo "  ❌ git        not found"
fi

# Node - usually only in homebrew
if [ -x "/opt/homebrew/bin/node" ]; then
    echo "  📗 node       $(/opt/homebrew/bin/node --version)"
    # Create alias if homebrew not in path
    alias node='/opt/homebrew/bin/node' 2>/dev/null
else
    echo "  ❌ node       not found (expected at /opt/homebrew/bin/node)"
fi

# npm - usually only in homebrew
if [ -x "/opt/homebrew/bin/npm" ]; then
    echo "  📦 npm        v$(/opt/homebrew/bin/npm --version)"
    # Create alias if homebrew not in path
    alias npm='/opt/homebrew/bin/npm' 2>/dev/null
else
    echo "  ❌ npm        not found (expected at /opt/homebrew/bin/npm)"
fi

# jq - check multiple locations
if [ -x "/usr/bin/jq" ]; then
    echo "  🔧 jq         $(/usr/bin/jq --version)"
elif [ -x "/opt/homebrew/bin/jq" ]; then
    echo "  🔧 jq         $(/opt/homebrew/bin/jq --version)"
else
    echo "  ❌ jq         not found"
fi

# wget - usually only in homebrew
if [ -x "/opt/homebrew/bin/wget" ]; then
    echo "  📥 wget       $(/opt/homebrew/bin/wget --version | head -1)"
    # Create alias if homebrew not in path
    alias wget='/opt/homebrew/bin/wget' 2>/dev/null
else
    echo "  ❌ wget       not found (expected at /opt/homebrew/bin/wget)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Setup complete!"
echo "🔄 Please restart Terminal or run: source ~/.zprofile"
echo ""
echo "Press any key to continue..."
read -n 1 -s

# Source the profile
source ~/.zprofile 
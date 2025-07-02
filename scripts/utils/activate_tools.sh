#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Tools Activator
# This script activates the tools immediately in the current shell

# Check if script is called with source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ This script must be called with source!"
    echo ""
    echo "Please run:"
    echo "  source activate_tools.sh"
    echo ""
    echo "or:"
    echo "  . activate_tools.sh"
    exit 1
fi

echo "🔄 Activating AdminHub tools..."
echo "© 2025 Luka Löhr"

# Add to PATH
export PATH="/opt/admin-tools/bin:$PATH"

# Check if tools are available
if command -v python3 &> /dev/null && [ -L "/opt/admin-tools/bin/python3" ]; then
    echo "✅ Tools activated!"
    echo ""
    echo "Available commands:"
    echo "  • python3 ($(python3 --version 2>&1))"
    echo "  • git ($(git --version))"
    
    if [ -L "/opt/admin-tools/bin/node" ]; then
        echo "  • node ($(node --version 2>/dev/null || echo 'Check permissions'))"
        echo "  • npm ($(npm --version 2>/dev/null || echo 'Check permissions'))"
    fi
    
    if [ -L "/opt/admin-tools/bin/jq" ]; then
        echo "  • jq ($(jq --version 2>/dev/null || echo 'Check permissions'))"
    fi
    
    if [ -L "/opt/admin-tools/bin/wget" ]; then
        echo "  • wget (installed)"
    fi
    
    echo ""
    echo "🎉 You can now use all tools in THIS terminal!"
    echo ""
    echo "Note: This activation applies only to the current terminal session."
    echo "New terminals will have the tools automatically if install_adminhub.sh was run"
else
    echo "❌ Tools not found. Please run: sudo ./install_adminhub.sh"
fi 
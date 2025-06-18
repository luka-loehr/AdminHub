#!/bin/bash

# AdminHub Tools Activator
# This script immediately activates the tools in the current shell

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ This script must be sourced, not executed!"
    echo ""
    echo "Please run:"
    echo "  source activate_tools.sh"
    echo ""
    echo "or:"
    echo "  . activate_tools.sh"
    exit 1
fi

echo "🔄 Activating AdminHub tools..."

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
        echo "  • node ($(node --version 2>/dev/null || echo 'check permissions'))"
        echo "  • npm ($(npm --version 2>/dev/null || echo 'check permissions'))"
    fi
    
    if [ -L "/opt/admin-tools/bin/jq" ]; then
        echo "  • jq ($(jq --version 2>/dev/null || echo 'check permissions'))"
    fi
    
    if [ -L "/opt/admin-tools/bin/wget" ]; then
        echo "  • wget (installed)"
    fi
    
    echo ""
    echo "🎉 You can now use all tools in THIS terminal!"
    echo ""
    echo "Note: This activation is only for the current terminal session."
    echo "New terminals will have the tools automatically if you ran install_adminhub.sh"
else
    echo "❌ Tools not found. Please run: sudo ./install_adminhub.sh"
fi 
#!/bin/bash

# AdminHub Guest Auto Setup
# This runs automatically when Guest user opens Terminal

# Only run for Guest user
if [[ "$(whoami)" != "Guest" ]]; then
    return 0 2>/dev/null || exit 0
fi

# Check if already initialized in this session
if [[ "$ADMINHUB_INITIALIZED" == "true" ]]; then
    return 0 2>/dev/null || exit 0
fi

# Mark as initialized
export ADMINHUB_INITIALIZED="true"

# Check if this is an interactive terminal (not a script or background process)
if [[ ! -t 0 ]]; then
    return 0 2>/dev/null || exit 0
fi

# Check if setup is needed (tools directory doesn't exist)
if [[ ! -d "/Users/Guest/tools/bin" ]]; then
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║     🚀 AdminHub Guest Setup 🚀         ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Setting up development tools..."
    echo ""
    
    # Run the actual setup
    if [[ -f /usr/local/bin/guest_setup_final.sh ]]; then
        /usr/local/bin/guest_setup_final.sh
    elif [[ -f /usr/local/bin/simple_guest_setup.sh ]]; then
        /usr/local/bin/simple_guest_setup.sh
    else
        echo "⚠️  Setup script not found!"
        echo "Please contact your administrator."
    fi
else
    # Tools already set up, just ensure PATH is correct
    export PATH="/Users/Guest/tools/bin:$PATH"
    
    # Show welcome message only once per session
    if [[ "$ADMINHUB_WELCOME_SHOWN" != "true" ]]; then
        export ADMINHUB_WELCOME_SHOWN="true"
        echo ""
        echo "✨ AdminHub tools are ready!"
        echo "Available: python3, git, node, npm, jq, wget"
        echo ""
    fi
fi 
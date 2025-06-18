#!/bin/bash

# Guest Shell Initializer
# Runs automatically when guest user opens Terminal

# Check if we're running as Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Check if this is the first run (to avoid running multiple times)
    MARKER_FILE="/tmp/.adminhub_guest_initialized"
    
    if [[ ! -f "$MARKER_FILE" ]]; then
        # Create marker file
        touch "$MARKER_FILE"
        
        # Run the guest setup script
        echo "=== AdminHub Guest Setup ==="
        echo "Setting up your environment..."
        echo ""
        
        # Execute the actual setup script
        if [[ -x /usr/local/bin/guest_setup_final.sh ]]; then
            /usr/local/bin/guest_setup_final.sh
        elif [[ -x /tmp/guest_setup_final.sh ]]; then
            /tmp/guest_setup_final.sh
        else
            echo "Error: Setup script not found!"
        fi
    fi
fi 
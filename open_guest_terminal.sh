#!/bin/bash

# Only run for Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Wait a moment for desktop to be ready
    sleep 2
    
    # Copy the setup script to a temp location
    cp /usr/local/bin/guest_setup_final.sh /tmp/guest_setup_final.sh 2>/dev/null
    chmod +x /tmp/guest_setup_final.sh
    
    # Open Terminal with 80x24 size and run the setup
    osascript <<EOF
tell application "Terminal"
    activate
    set newTab to do script "/tmp/guest_setup_final.sh"
    
    -- Set terminal size to 80x24
    tell window 1
        set number of columns to 80
        set number of rows to 24
    end tell
end tell
EOF
fi 
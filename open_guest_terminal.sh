#!/bin/bash

# Only open Terminal for Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Wait a moment for desktop to be ready
    sleep 2
    
    # Copy the simple setup script to temp location
    cp /usr/local/bin/simple_guest_setup.sh /tmp/simple_guest_setup.sh 2>/dev/null
    chmod +x /tmp/simple_guest_setup.sh
    
    # Open Terminal and run the setup script
    osascript <<EOF
tell application "Terminal"
    activate
    do script "/tmp/simple_guest_setup.sh"
    set bounds of front window to {100, 100, 900, 600}
end tell
EOF
fi 
#!/bin/bash

# Only run for Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Wait a moment for desktop to be ready
    sleep 2
    
    # Open Terminal immediately and run the background setup inside it
    osascript <<EOF
tell application "Terminal"
    activate
    do script "echo '🚀 Setting up AdminHub tools...'; echo ''; /usr/local/bin/guest_setup_background.sh"
    set bounds of front window to {100, 100, 900, 600}
end tell
EOF
fi 
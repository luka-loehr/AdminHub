#!/bin/bash

# Only open Terminal for Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Wait a moment for desktop to be ready
    sleep 2
    
    # Open Terminal and run the setup script
    osascript <<EOF
tell application "Terminal"
    activate
    do script "clear && echo '🎯 AdminHub Guest Tools Setup' && echo '===================================' && echo '' && /usr/local/bin/guest_tools_setup.sh setup --in-terminal"
    set bounds of front window to {100, 100, 900, 600}
end tell
EOF
fi 
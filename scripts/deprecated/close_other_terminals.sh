#!/bin/bash

# Close all Terminal windows except the front one
osascript <<'EOF'
tell application "Terminal"
    -- Get the front window (the new one we want to keep)
    set keepWindow to front window
    
    -- Get all windows
    set allWindows to every window
    
    -- Close each window except the one we want to keep
    repeat with w in allWindows
        if w is not keepWindow then
            try
                close w
            end try
        end if
    end repeat
end tell
EOF 
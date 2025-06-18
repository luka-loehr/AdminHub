#!/bin/bash

# Open Terminal at Guest login
# Simple script that opens Terminal without AppleScript permissions

# Only run for Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Wait for desktop to be ready
    sleep 2
    
    # Open Terminal using the open command (no permissions needed)
    /usr/bin/open -a Terminal
fi 
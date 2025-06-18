#!/bin/bash

# Only run for Guest user
if [[ "$(whoami)" == "Guest" ]]; then
    # Run the background setup script
    /usr/local/bin/guest_setup_background.sh &
fi 
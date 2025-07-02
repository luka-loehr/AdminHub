#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Guest Login Setup
# Runs automatically when the Guest user logs in (via LaunchAgent)

# Only run for Guest user
if [[ "$(whoami)" != "Guest" ]]; then
    exit 0
fi

# Log startup
echo "[$(date)] Guest Login Setup started" >> /tmp/adminhub-setup.log

# Guest home directory (recreated on every login)
GUEST_HOME="/Users/Guest"

# Wait briefly until the home directory is fully created
sleep 1

# Create .zshrc with our auto-setup
echo "[$(date)] Creating .zshrc" >> /tmp/adminhub-setup.log
cat > "$GUEST_HOME/.zshrc" << 'EOF'
# AdminHub Guest Setup
# Automatically generated at login

# Load the auto-setup script
if [ -f /usr/local/bin/guest_setup_auto.sh ]; then
    source /usr/local/bin/guest_setup_auto.sh
fi
EOF

# Create .bash_profile for Bash compatibility
echo "[$(date)] Creating .bash_profile" >> /tmp/adminhub-setup.log
cat > "$GUEST_HOME/.bash_profile" << 'EOF'
# AdminHub Guest Setup
# Automatically generated at login

# Load the auto-setup script
if [ -f /usr/local/bin/guest_setup_auto.sh ]; then
    source /usr/local/bin/guest_setup_auto.sh
fi
EOF

# Set permissions
chmod 644 "$GUEST_HOME/.zshrc" "$GUEST_HOME/.bash_profile" 2>/dev/null || true

# Automatically open Terminal
echo "[$(date)] Opening Terminal" >> /tmp/adminhub-setup.log
/usr/bin/open -a Terminal

echo "[$(date)] Guest Login Setup completed" >> /tmp/adminhub-setup.log 
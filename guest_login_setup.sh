#!/bin/bash

# AdminHub Guest Login Setup
# This runs automatically when Guest user logs in (via LaunchAgent)

# Only run for Guest user
if [[ "$(whoami)" != "Guest" ]]; then
    exit 0
fi

# Log for debugging
echo "[$(date)] Starting Guest login setup" >> /tmp/adminhub-setup.log

# Guest home directory (will be fresh on each login)
GUEST_HOME="/Users/Guest"

# Wait a moment for the home directory to be fully created
sleep 1

# Create .zshrc with our auto-setup
echo "[$(date)] Creating .zshrc" >> /tmp/adminhub-setup.log
cat > "$GUEST_HOME/.zshrc" << 'EOF'
# AdminHub Guest Setup
# Auto-generated at login

# Source the auto setup script
if [ -f /usr/local/bin/guest_setup_auto.sh ]; then
    source /usr/local/bin/guest_setup_auto.sh
fi
EOF

# Create .bash_profile for bash compatibility
echo "[$(date)] Creating .bash_profile" >> /tmp/adminhub-setup.log
cat > "$GUEST_HOME/.bash_profile" << 'EOF'
# AdminHub Guest Setup
# Auto-generated at login

# Source the auto setup script
if [ -f /usr/local/bin/guest_setup_auto.sh ]; then
    source /usr/local/bin/guest_setup_auto.sh
fi
EOF

# Set proper permissions
chmod 644 "$GUEST_HOME/.zshrc" "$GUEST_HOME/.bash_profile" 2>/dev/null || true

# Open Terminal automatically
echo "[$(date)] Opening Terminal" >> /tmp/adminhub-setup.log
/usr/bin/open -a Terminal

echo "[$(date)] Guest login setup completed" >> /tmp/adminhub-setup.log 
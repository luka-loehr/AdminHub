#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Fix Homebrew permissions so Guest can use the tools

echo "🔧 Fixing Homebrew permissions for Guest access..."

# Make Homebrew directories readable for all
sudo chmod -R o+rX /opt/homebrew/bin 2>/dev/null || true
sudo chmod -R o+rX /opt/homebrew/lib 2>/dev/null || true
sudo chmod -R o+rX /opt/homebrew/share 2>/dev/null || true

# Fix permissions for installed tools (only if they exist)
for tool in node wget git; do
    if [ -d "/opt/homebrew/Cellar/$tool" ]; then
        sudo chmod -R o+rX "/opt/homebrew/Cellar/$tool"
    fi
done

# Fix permissions for admin tools directory
sudo chmod -R o+rX /opt/admin-tools 2>/dev/null || true

# Fix LaunchAgent permissions
if [ -f "/Library/LaunchAgents/com.adminhub.guestsetup.plist" ]; then
    sudo chmod 644 /Library/LaunchAgents/com.adminhub.guestsetup.plist
    sudo chown root:wheel /Library/LaunchAgents/com.adminhub.guestsetup.plist
fi

echo "✅ Permissions fixed!"
echo ""
echo "The following tools should now be accessible for Guest:"
echo "  - Python 3 (from system)"
echo "  - Git (from /opt/homebrew/bin/)"
echo "  - Node.js & npm (from /opt/homebrew/bin/)"
echo "  - wget (from /opt/homebrew/bin/)"
echo "  - jq (from system)" 
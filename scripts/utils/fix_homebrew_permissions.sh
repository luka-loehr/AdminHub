#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Fix Homebrew permissions so Guest can use the tools

echo "🔧 Fixing Homebrew permissions for Guest access..."

# Make Homebrew directories readable for all
sudo chmod -R o+rX /opt/homebrew/bin
sudo chmod -R o+rX /opt/homebrew/Cellar/node
sudo chmod -R o+rX /opt/homebrew/Cellar/wget
sudo chmod -R o+rX /opt/homebrew/Cellar/jq
sudo chmod -R o+rX /opt/homebrew/Cellar/git
sudo chmod -R o+rX /opt/homebrew/lib
sudo chmod -R o+rX /opt/homebrew/share

echo "✅ Permissions fixed!"
echo ""
echo "The following tools should now be accessible for Guest:"
echo "  - node, npm (from /opt/homebrew/bin/)"
echo "  - wget (from /opt/homebrew/bin/)"
echo "  - jq (from /opt/homebrew/bin/)"
echo "  - git (from /opt/homebrew/bin/)" 
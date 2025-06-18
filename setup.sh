#!/bin/bash

# AdminHub Quick Setup Script
# This is the main entry point for setting up AdminHub

set -e

echo "🚀 AdminHub Setup"
echo "================="
echo ""

# Check if running as sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./setup.sh"
    exit 1
fi

# Run the main installation
echo "Starting installation..."
./scripts/install/install_adminhub.sh

echo ""
echo "✅ Setup complete!"
echo ""
echo "For the permission-free Guest setup, run:"
echo "  sudo ./scripts/setup/setup_guest_shell_init.sh" 
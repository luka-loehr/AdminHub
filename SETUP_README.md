# AdminHub Setup Guide for New MacBooks

## Overview
AdminHub provides development tools to Guest accounts on macOS with zero-persistence. This guide explains how to install and configure the system on new MacBooks.

## Files Included

### Core Scripts
- **`guest_tools_setup.sh`** - Main setup script that installs all development tools via Homebrew
- **`simple_guest_setup.sh`** - Script that runs on Guest login to configure PATH and show available tools
- **`open_guest_terminal.sh`** - Script that opens Terminal automatically for Guest users

### Fix Scripts
- **`fix_homebrew_permissions.sh`** - Fixes permissions on Homebrew directories to make tools accessible to Guest

### LaunchAgent
- **`com.adminhub.guestterminal.plist`** - LaunchAgent that automatically opens Terminal on Guest login

## Installation Steps for New MacBook

### 1. Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone the AdminHub Repository
```bash
cd ~/Documents
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub
```

### 3. Run the Main Setup Script
```bash
sudo ./guest_tools_setup.sh
```
This will:
- Create `/opt/admin-tools/bin/` directory
- Install Python3, Git, Node.js, npm, jq, wget via Homebrew
- Create symlinks in `/opt/admin-tools/bin/`
- Install the Terminal opener script
- Configure the LaunchAgent

### 4. Fix Homebrew Permissions
```bash
sudo ./fix_homebrew_permissions.sh
```
This ensures Guest users can access all installed tools.

### 5. Verify Installation
1. Log out of your admin account
2. Log in as Guest
3. Terminal should open automatically showing:
   - Available tools with icons
   - Tool versions
   - Ready-to-use prompt

## Installed Tools
- **Python** - Python 3.9.6+ with pip
- **Git** - Version control system
- **Node.js** - JavaScript runtime
- **npm** - Node package manager
- **jq** - JSON processor
- **wget** - File downloader

## Directory Structure
```
/opt/admin-tools/
└── bin/                  # Symlinks to Homebrew tools
    ├── python3
    ├── pip3
    ├── git
    ├── node
    ├── npm
    ├── jq
    └── wget

/usr/local/bin/
├── open_guest_terminal   # Terminal opener script
└── simple_guest_setup.sh # Guest setup script

/Library/LaunchAgents/
└── com.adminhub.guestterminal.plist  # LaunchAgent
```

## Troubleshooting

### Tools Not Found
If tools show "not found" for Guest:
```bash
sudo ./fix_homebrew_permissions.sh
```

### Terminal Not Opening
Check LaunchAgent:
```bash
sudo launchctl list | grep adminhub
```

### Permission Issues
Ensure all scripts are executable:
```bash
chmod +x *.sh
```

## Important Notes
- Guest accounts have zero-persistence - all changes are lost on logout
- Tools are installed system-wide but only accessible to Guest via `/opt/admin-tools/bin/`
- The system requires admin privileges to install but runs as Guest user

## Future Development
- GUI version using Swift/SwiftUI
- Remote management capabilities
- Device tracking and monitoring
- Automatic updates

## Contact
For issues or questions about the school deployment, contact the IT administration team. 
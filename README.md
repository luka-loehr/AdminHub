# AdminHub - Developer Tools for Guest Accounts 🎓

**Instantly provide coding tools to Guest users on macOS**

[![Version](https://img.shields.io/badge/version-2.1.0-blue)](https://github.com/luka-loehr/AdminHub)
[![macOS](https://img.shields.io/badge/macOS-10.14%2B-success)](https://support.apple.com/macos)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## What is AdminHub? 🤔

AdminHub lets teachers and IT admins install developer tools once, making them automatically available to all Guest users - no setup needed by students!

**New in v2.1.0:** Full support for older Macs (4+ years without updates), automatic system repairs, and one-command updates from GitHub.

## Quick Start 🚀

### Prerequisites
- macOS 10.14 (Mojave) or newer
- Admin access
- [Homebrew](https://brew.sh) installed
- Guest account enabled
- 5GB free disk space

### Installation (3 minutes)

1. **Clone the repository**
   ```bash
   git clone https://github.com/luka-loehr/AdminHub.git
   cd AdminHub
   ```

2. **Run installation**
   ```bash
   sudo ./scripts/adminhub-cli.sh install
   ```

3. **Check status**
   ```bash
   sudo ./scripts/adminhub-cli.sh status
   ```
   
   All components should show "✅ HEALTHY"

That's it! Guest users now have instant access to developer tools.

## Available Tools 🛠️

- **Homebrew** - Package manager
- **Python 3 & Python** - Programming language (with pip/pip3)
- **Git** - Version control

## For Students 👨‍🎓

Just log in as Guest - Terminal opens automatically with all tools ready!

```bash
python3              # Start Python 3
python               # Start Python
git --version        # Check Git
brew --version       # Check Homebrew
```

## Common Commands 📋

```bash
# Check system health
sudo ./scripts/adminhub-cli.sh status

# Update to latest version
./scripts/adminhub-cli.sh update

# View logs
./scripts/adminhub-cli.sh logs error  # Error logs
./scripts/adminhub-cli.sh logs info   # Info logs
./scripts/adminhub-cli.sh logs debug  # Debug logs

# Monitor system health
./scripts/adminhub-cli.sh monitor

# Fix permissions
sudo ./scripts/adminhub-cli.sh permissions fix

# Uninstall
sudo ./scripts/adminhub-cli.sh uninstall
```

## Features ✨

- **Automatic Setup**: Tools ready instantly when Guest logs in
- **Old Mac Support**: Works on macOS 10.14+ (Mojave and newer)
- **Self-Healing**: Automatic repairs for common issues
- **One-Command Updates**: Pull latest version from GitHub
- **Comprehensive Monitoring**: Health checks and system status
- **Clean Guest Logout**: Everything resets automatically

## Updating AdminHub 🔄

Keep AdminHub up to date with one command:

```bash
./scripts/adminhub-cli.sh update
```

This will:
- Check for updates on GitHub
- Back up your current configuration
- Download and apply updates
- Rerun installation if needed

## Troubleshooting 🛠️

**Terminal doesn't open for Guest?**
- Check status: `sudo ./scripts/adminhub-cli.sh status`
- Reinstall if needed: `sudo ./scripts/adminhub-cli.sh install`

**Status shows "DEGRADED"?**
- Run with sudo: `sudo ./scripts/adminhub-cli.sh status`
- Without sudo, some checks can't run properly

**Old Mac having issues?**
- AdminHub automatically detects and repairs common issues on older systems
- Check compatibility: `./scripts/utils/old_mac_compatibility.sh`
- View repair log: `./scripts/adminhub-cli.sh logs info`

**Need help?**
```bash
./scripts/adminhub-cli.sh --help
```

## How It Works 🔧

1. **Compatibility Check**: Validates system requirements (macOS version, disk space, etc.)
2. **System Repair**: Fixes common issues (certificates, Git config, permissions)
3. **Tool Installation**: Installs to `/opt/admin-tools/`
4. **Guest Login**: LaunchAgent automatically sets up environment
5. **Auto-Cleanup**: Everything resets when Guest logs out

## Advanced Usage 🔧

### CLI Commands

```bash
# Installation & Management
adminhub install              # Install AdminHub
adminhub uninstall            # Remove AdminHub
adminhub update               # Update from GitHub

# System Status
adminhub status               # Quick health check
adminhub health detailed      # Comprehensive health check
adminhub monitor              # Continuous monitoring

# Configuration
adminhub config show          # View configuration
adminhub config set KEY VALUE # Change settings

# Logs & Debugging
adminhub logs error           # View error logs
adminhub logs info            # View info logs
adminhub logs debug           # View debug logs

# Maintenance
adminhub permissions fix      # Fix file permissions
adminhub tools list           # List available tools
```

### For Old Macs (4+ years without updates)

AdminHub includes special support for older systems:

```bash
# Check compatibility
./scripts/utils/old_mac_compatibility.sh

# Run system repairs manually
sudo ./scripts/utils/system_repair.sh

# Fix Homebrew issues
sudo ./scripts/utils/homebrew_repair.sh
```

## License 📄

MIT License - © 2025 Luka Löhr

Created for Lessing-Gymnasium Karlsruhe to make coding education accessible.
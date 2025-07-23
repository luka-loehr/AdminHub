# AdminHub

Automated developer tool deployment for macOS Guest accounts.

[![Version](https://img.shields.io/badge/version-2.1.0-blue)](https://github.com/luka-loehr/AdminHub)
[![macOS](https://img.shields.io/badge/macOS-10.14%2B-success)](https://support.apple.com/macos)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Overview

AdminHub automatically provides development tools to Guest users on shared Macs. IT admins install once, students get instant access.

**Tools included:**
- Python 3 & Python (with pip)
- Git
- Homebrew

## Requirements

- macOS 10.14 (Mojave) or newer
- Admin access
- [Homebrew](https://brew.sh) installed
- Guest account enabled
- 5GB free disk space

## Installation

```bash
# Clone repository
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub

# Install (includes automatic system repairs for old Macs)
sudo ./scripts/adminhub-cli.sh install

# Verify installation
sudo ./scripts/adminhub-cli.sh status
```

All components should show "✅ HEALTHY".

## Usage

### For IT Admins

**Basic Commands**
```bash
sudo ./scripts/adminhub-cli.sh status     # Check system health
./scripts/adminhub-cli.sh update          # Update from GitHub
sudo ./scripts/adminhub-cli.sh uninstall  # Remove AdminHub
```

**Troubleshooting**
```bash
sudo ./scripts/adminhub-cli.sh health detailed    # Detailed diagnostics
sudo ./scripts/adminhub-cli.sh permissions fix    # Fix permission issues
./scripts/adminhub-cli.sh logs error              # View error logs
./scripts/adminhub-cli.sh --help                  # Show all commands
```

### For Students

Log in as Guest. Terminal opens automatically with all tools ready.

## Architecture

- **Tools Location**: `/opt/admin-tools/`
- **Configuration**: `/etc/adminhub/adminhub.conf`
- **Logs**: `/var/log/adminhub/`
- **LaunchAgent**: `/Library/LaunchAgents/com.adminhub.guestsetup.plist`

## How It Works

1. Admin installs tools to `/opt/admin-tools/`
2. LaunchAgent activates on Guest login
3. Tools added to Guest's PATH
4. Everything resets on Guest logout

## CLI Reference

```bash
# Core Commands
adminhub install              # Install system
adminhub uninstall            # Remove system
adminhub update               # Update from GitHub
adminhub status               # Quick health check

# Diagnostics
adminhub health detailed      # Full system check
adminhub logs [error|info|debug]  # View logs
adminhub permissions fix      # Fix file permissions

# Configuration
adminhub config show          # View settings
adminhub config set KEY VALUE # Change settings
adminhub tools list           # List available tools
```

## Support

- **Installation fails**: Check prerequisites and disk space
- **Status shows DEGRADED**: Run with sudo for full diagnostics
- **Tools not available**: Check Guest account settings

## License

MIT License - © 2025 Luka Löhr

Created for Lessing-Gymnasium Karlsruhe.
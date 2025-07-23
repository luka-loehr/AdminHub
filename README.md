# AdminHub

Automated developer tool deployment for macOS Guest accounts.

[![Version](https://img.shields.io/badge/version-2.1.0-blue)](https://github.com/luka-loehr/AdminHub)
[![macOS](https://img.shields.io/badge/macOS-10.14%2B-success)](https://support.apple.com/macos)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Overview

AdminHub automatically provides development tools to Guest users on shared Macs with enterprise-grade security.

**Tools included:**
- Python 3 & Python (with pip)
- Git
- Homebrew

**Security features:**
- All Guest modifications are user-local only
- System-wide installations are blocked
- Changes reset on logout
- No risk of students breaking tools

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

```bash
sudo ./scripts/adminhub-cli.sh status     # Check if working
./scripts/adminhub-cli.sh update          # Update from GitHub
sudo ./scripts/adminhub-cli.sh uninstall  # Remove AdminHub
```

If status shows issues, check logs:
```bash
./scripts/adminhub-cli.sh logs error     # View error logs
```

## Architecture

- **Tools Location**: `/opt/admin-tools/`
- **Configuration**: `/etc/adminhub/adminhub.conf`
- **Logs**: `/var/log/adminhub/`
- **LaunchAgent**: `/Library/LaunchAgents/com.adminhub.guestsetup.plist`

## How It Works

1. Admin installs tools to `/opt/admin-tools/`
2. Security wrappers prevent system modifications
3. LaunchAgent activates on Guest login
4. Tools added to Guest's PATH
5. All Guest changes stay in their home directory
6. Everything resets on Guest logout

## Security

AdminHub implements strict security for Guest users:

- **Blocked Operations**:
  - `brew install/uninstall` - No system packages
  - `pip install` without `--user` - Auto-adds flag
  - `npm install -g` - No global packages
  - `sudo` commands - Completely disabled
  
- **Allowed Operations**:
  - `pip install --user numpy` - Installs to ~/.local
  - `brew list` - View installed packages
  - `python script.py` - Run Python code
  - `git clone` - Work with repositories

All Guest modifications are isolated to their session and automatically cleaned on logout.

For detailed security architecture and rationale, see [SECURITY.md](SECURITY.md).

## Troubleshooting

- **Installation fails**: Check prerequisites and disk space
- **Status shows issues**: Check error logs with `adminhub logs error`
- **Need more commands**: Run `adminhub --help`

## License

MIT License - © 2025 Luka Löhr

Created for Lessing-Gymnasium Karlsruhe.
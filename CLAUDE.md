# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AdminHub is a macOS system administration tool that automatically provides developer tools (Python, Git, Homebrew) to Guest accounts on shared computers, primarily for educational environments.

## Key Commands

### Building Packages
```bash
# Build both installer and uninstaller packages
./build_all_packages.sh

# Build only the installer
./build_installer.sh
```

### Development & Testing
```bash
# Install AdminHub (requires sudo)
sudo ./scripts/adminhub-cli.sh install

# Check system status
sudo ./scripts/adminhub-cli.sh status

# View logs (error/info/debug)
./scripts/adminhub-cli.sh logs error

# Monitor system health
./scripts/adminhub-cli.sh monitor

# Uninstall
sudo ./scripts/adminhub-cli.sh uninstall
```

### No Automated Tests
This project uses manual testing via the CLI status and health commands. There are no unit tests, integration tests, or linting commands.

## Architecture & Code Structure

### Core Components

1. **CLI Management System** (`scripts/adminhub-cli.sh`)
   - Central management interface for all AdminHub operations
   - Bash 3.2 compatible (macOS default)
   - Modular command structure with subcommands

2. **Utility Modules** (`scripts/utils/`)
   - `logging.sh`: Centralized logging with rotation and severity levels
   - `config.sh`: Configuration management and validation
   - `monitoring.sh`: Health monitoring and alerting system
   - All modules follow strict bash error handling (`set -euo pipefail`)

3. **Guest Setup Pipeline**
   - `launchagents/com.adminhub.guestsetup.plist`: Triggers on Guest login
   - `scripts/setup/guest_login_setup.sh`: Main setup orchestrator
   - `scripts/setup/guest_tools_setup.sh`: Tool installation logic
   - `scripts/setup/setup_guest_shell_init.sh`: Shell environment configuration

### Important Paths
- Tool storage: `/opt/admin-tools/`
- Configuration: `/etc/adminhub/adminhub.conf`
- Logs: `/var/log/adminhub/`
- LaunchAgent: `/Library/LaunchAgents/com.adminhub.guestsetup.plist`

### Bash Compatibility
- **MUST** maintain compatibility with Bash 3.2 (macOS default)
- Avoid bash 4+ features (associative arrays, etc.)
- Use POSIX-compliant constructs where possible

### Error Handling Pattern
All scripts follow this pattern:
```bash
set -euo pipefail  # Strict error handling
source logging/config utilities
check prerequisites
perform operations with extensive logging
cleanup on exit
```

### Package Building
Uses native macOS tools (`pkgbuild`, `productbuild`) to create signed installer packages. The build process:
1. Stages files in `pkg_build/` directories
2. Creates component packages
3. Builds distribution packages with pre/post-install scripts
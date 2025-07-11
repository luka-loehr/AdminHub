# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AdminHub is a macOS system administration tool that automatically provides developer tools (Python, Git, Homebrew) to Guest accounts on shared computers, primarily for educational environments.

## Key Commands

### Installation & Management
```bash
# Install AdminHub (requires sudo)
sudo ./scripts/adminhub-cli.sh install

# Check system status - all components should show "✅ HEALTHY"
sudo ./scripts/adminhub-cli.sh status

# View logs (error/info/debug)
./scripts/adminhub-cli.sh logs error
./scripts/adminhub-cli.sh logs info
./scripts/adminhub-cli.sh logs debug

# Monitor system health continuously
./scripts/adminhub-cli.sh monitor

# Uninstall
sudo ./scripts/adminhub-cli.sh uninstall
```

### No Automated Tests
This project uses manual testing via the CLI status and health commands. There are no unit tests, integration tests, or linting commands.

## Architecture & Code Structure

### Core Components

1. **CLI Management System** (`scripts/adminhub-cli.sh`)
   - Central management interface for all AdminHub operations (v2.0.1)
   - Bash 3.2 compatible (macOS default)
   - Modular command structure with subcommands
   - Commands: install, uninstall, status, logs, monitor

2. **Installation Scripts**
   - `scripts/install_adminhub.sh`: Main installation orchestrator
   - `scripts/uninstall.sh`: Clean uninstallation process
   - Both scripts check prerequisites and handle permissions

3. **Utility Modules** (`scripts/utils/`)
   - `logging.sh`: Centralized logging with rotation and severity levels
   - `config.sh`: Configuration management and validation
   - `monitoring.sh`: Health monitoring and alerting system
   - `activate_tools.sh`: Tool activation for Guest users
   - `fix_homebrew_permissions.sh`: Homebrew permission management
   - All modules follow strict bash error handling (`set -euo pipefail`)

4. **Guest Setup Pipeline**
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
- Avoid bash 4+ features (associative arrays, mapfile, etc.)
- Use POSIX-compliant constructs where possible
- Test on macOS with `/bin/bash --version` (should be 3.2.x)

### Error Handling Pattern
All scripts follow this pattern:
```bash
#!/bin/bash
set -euo pipefail  # Strict error handling

# Source utilities
source "$(dirname "$0")/utils/logging.sh"
source "$(dirname "$0")/utils/config.sh"

# Check prerequisites
check_sudo || exit 1
check_homebrew || exit 1

# Perform operations with extensive logging
log_info "Starting operation..."
# ... main logic ...

# Cleanup on exit (if needed)
trap cleanup EXIT
```

### Logging Standards
- Use `log_error`, `log_info`, `log_debug` from `logging.sh`
- Logs stored in `/var/log/adminhub/` with automatic rotation
- Always log significant operations and state changes
- Include context in error messages

### Package Building (Not Currently Implemented)
The CLAUDE.md references build scripts that don't exist in the repository:
- `./build_all_packages.sh` - Would build installer and uninstaller packages
- `./build_installer.sh` - Would build only the installer

If implementing package building, use native macOS tools:
1. `pkgbuild` for component packages
2. `productbuild` for distribution packages
3. Stage files in `pkg_build/` directories
4. Include pre/post-install scripts
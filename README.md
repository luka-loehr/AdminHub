# AdminHub v2.0

<p align="center">
  <img src="https://img.shields.io/badge/macOS-10.14+-blue?style=flat-square&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Python-3.x-green?style=flat-square&logo=python" alt="Python">
  <img src="https://img.shields.io/badge/Node.js-Latest-green?style=flat-square&logo=node.js" alt="Node.js">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Version-2.0.1-brightgreen?style=flat-square" alt="Version">
</p>

<p align="center">
  <strong>🚀 Enterprise-Grade Automated Development Tools for macOS Guest Accounts</strong><br>
  <em>Entwickelt für das Lessing-Gymnasium Karlsruhe</em>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#cli-commands">CLI Commands</a> •
  <a href="#monitoring">Monitoring</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#troubleshooting">Troubleshooting</a> •
  <a href="#license">License</a>
</p>

---

## 📋 Overview

AdminHub is an enterprise-grade automated system for providing development tools to Guest accounts on macOS. Version 2.0 introduces advanced monitoring, centralized configuration management, comprehensive logging, and a powerful CLI interface while maintaining the original simplicity for end users.

### 🎯 Problem & Solution

**Problem:** Guest accounts on macOS lose all data on logout. Students need to reinstall tools every session.

**Solution:** AdminHub installs tools persistently and makes them automatically available to every Guest - with zero user interaction and enterprise-grade monitoring!

## ✨ Features

### 🚀 Core Features
- **Fully Automated** - Terminal opens at Guest login with all tools ready
- **Zero Permissions** - Runs completely without AppleScript permissions
- **Lightning Fast** - Tools available in seconds
- **Education-Friendly** - Perfect for computer science classes
- **Complete Toolkit** - Python, Git, Node.js, npm, jq, wget pre-installed
- **Bash 3.2 Compatible** - Works with macOS default bash (no updates needed)

### 🎛️ New in v2.0: Enterprise Features
- **🖥️ Advanced CLI Interface** - Comprehensive command-line management
- **📊 Real-time System Monitoring** - Health checks and performance metrics
- **⚙️ Centralized Configuration** - Hierarchical config management
- **📝 Structured Logging** - 5-level logging with automatic rotation
- **🔧 Self-Healing** - Automatic error recovery and repair functions
- **📈 Status Dashboard** - JSON status output for integration
- **🚨 Alert System** - Proactive issue detection and notification

## 📦 Included Tools

| Tool | Version | Description | Status |
|------|---------|-------------|--------|
| **Python 3** | 3.9.6+ | Programming language with pip3 | ✅ Active |
| **Git** | 2.50.0+ | Version control system | ✅ Active |
| **Node.js** | 24.2.0+ | JavaScript runtime | ✅ Active |
| **npm** | 11.3.0+ | Node package manager | ✅ Active |
| **jq** | 1.7.1+ | JSON processor | ✅ Active |
| **wget** | 1.25.0+ | File downloader | ✅ Active |
| **pip3** | 21.2.4+ | Python package installer | ✅ Active |

## 🚀 Quick Start

### Prerequisites

- macOS 10.14 or newer
- Administrator access
- [Homebrew](https://brew.sh) installed
- Guest account enabled (System Preferences → Users & Groups)

### Installation

```bash
# Clone repository
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub

# Run installation (as admin)
sudo ./setup.sh
```

When asked "Should I install the missing tools now?" answer **y**.

**That's it!** Installation is fully automated.

### Verification

```bash
# Test installation
./test.sh

# Check system health
./adminhub-cli.sh status

# View detailed status
./adminhub-cli.sh health detailed
```

## 🖥️ CLI Commands

AdminHub v2.0 introduces a comprehensive CLI interface for system management:

### Installation & Setup
```bash
./adminhub-cli.sh install           # Full installation
./adminhub-cli.sh install tools     # Install tools only
./adminhub-cli.sh install agent     # Install LaunchAgent only
./adminhub-cli.sh uninstall         # Remove AdminHub
./adminhub-cli.sh update           # Update to latest version
./adminhub-cli.sh repair           # Repair broken installation
```

### System Management
```bash
./adminhub-cli.sh status           # Show system status
./adminhub-cli.sh status detailed  # Detailed status
./adminhub-cli.sh status json      # JSON output
./adminhub-cli.sh health           # Run health checks
./adminhub-cli.sh health detailed  # Detailed health analysis
./adminhub-cli.sh monitor          # Start continuous monitoring
```

### Configuration Management
```bash
./adminhub-cli.sh config show      # Show current configuration
./adminhub-cli.sh config edit      # Edit configuration file
./adminhub-cli.sh config reset     # Reset to defaults
./adminhub-cli.sh config validate  # Validate configuration
./adminhub-cli.sh config set <key> <value>  # Set configuration value
```

### Tool Management
```bash
./adminhub-cli.sh tools list       # List configured tools
./adminhub-cli.sh tools versions   # Show tool versions
./adminhub-cli.sh tools test       # Test all tools
./adminhub-cli.sh tools test <tool> # Test specific tool
./adminhub-cli.sh tools install <tool> # Install specific tool
```

### Guest Management
```bash
./adminhub-cli.sh guest setup      # Setup guest environment
./adminhub-cli.sh guest test       # Test guest setup
./adminhub-cli.sh guest cleanup    # Cleanup guest tools
```

### Logs & Monitoring
```bash
./adminhub-cli.sh logs             # View recent logs
./adminhub-cli.sh logs error       # View error logs
./adminhub-cli.sh logs guest       # View guest setup logs
./adminhub-cli.sh logs alerts      # View system alerts
./adminhub-cli.sh logs tail        # Tail live logs
./adminhub-cli.sh logs clear       # Clear all logs
```

### System Maintenance
```bash
./adminhub-cli.sh permissions fix  # Fix file permissions
./adminhub-cli.sh permissions check # Check permissions

# Global options
./adminhub-cli.sh --help           # Show help
./adminhub-cli.sh --version        # Show version
./adminhub-cli.sh --verbose <cmd>  # Verbose output
./adminhub-cli.sh --dry-run <cmd>  # Dry run mode
./adminhub-cli.sh --force <cmd>    # Force operations
```

## 📊 Monitoring & Health Checks

AdminHub v2.0 includes comprehensive monitoring capabilities:

### Health Components
- **🔧 Admin Tools** - Verifies all 7 tools are working correctly
- **👤 Guest Setup** - Checks guest scripts and LaunchAgent
- **🚀 LaunchAgent** - Monitors auto-start service status
- **🍺 Homebrew** - Validates Homebrew installation health
- **🔐 Permissions** - Ensures correct file permissions
- **💾 Disk Space** - Monitors available storage

### Health Status Levels
- **✅ HEALTHY** - All components functioning normally
- **⚠️ DEGRADED** - Some issues but system functional
- **❌ UNHEALTHY** - Critical issues requiring attention

### Example Health Check Output
```bash
$ ./adminhub-cli.sh status

╔═══════════════════════════════════════╗
║         AdminHub Health Status        ║
╚═══════════════════════════════════════╝

🏥 Overall Status: HEALTHY

📊 Component Status:
  admin_tools:    ✅ HEALTHY
  guest_setup:    ✅ HEALTHY
  launchagent:    ✅ HEALTHY
  homebrew:       ✅ HEALTHY
  permissions:    ✅ HEALTHY
  disk_space:     ✅ HEALTHY

📈 Metrics:
  Tools Available: 7/7
  Last Check:      2025-07-02 15:47:18
  System Uptime:   2d 21h 46m
```

## ⚙️ Configuration

AdminHub uses a hierarchical configuration system:

### Configuration Files
- **System-wide**: `/etc/adminhub/adminhub.conf` (admin only)
- **User-specific**: `~/.adminhub.conf` (user overrides)

### Key Configuration Options
```bash
# Paths
ADMIN_TOOLS_DIR=/opt/admin-tools
GUEST_TOOLS_DIR=/Users/Guest/tools
SCRIPTS_DIR=/usr/local/bin

# Tool Configuration
TOOLS_LIST=python3,git,node,npm,jq,wget,pip3
HOMEBREW_TOOLS=git,node,jq,wget
SYSTEM_TOOLS=python3,pip3

# Behavior Settings
AUTO_INSTALL_MISSING=true
OPEN_TERMINAL_ON_LOGIN=true
SHOW_WELCOME_MESSAGE=true
GUEST_SETUP_TIMEOUT=30

# Logging Configuration
LOG_LEVEL=INFO
LOG_RETENTION_DAYS=30
ENABLE_DEBUG_LOGGING=false
```

### Configuration Commands
```bash
# View configuration
./adminhub-cli.sh config show

# Edit configuration
./adminhub-cli.sh config edit

# Set specific values
./adminhub-cli.sh config set LOG_LEVEL DEBUG
./adminhub-cli.sh config set GUEST_SETUP_TIMEOUT 60

# Reset to defaults
./adminhub-cli.sh config reset
```

## 💻 Usage

### For Administrators

AdminHub v2.0 provides powerful management tools:

```bash
# Monitor system health
./adminhub-cli.sh monitor

# Check logs
./adminhub-cli.sh logs tail

# Repair issues
./adminhub-cli.sh repair

# Update system
./adminhub-cli.sh update
```

### For Students/Guest Users

The experience remains seamless:

1. Log in as **Guest**
2. Terminal opens automatically
3. All tools immediately available!

```bash
# Development examples
python3 --version
git clone https://github.com/example/project.git
npm install express
wget https://example.com/file.zip
echo '{"name":"test"}' | jq .
```

## 🏗️ Technical Architecture

### Directory Structure
```
AdminHub/
├── setup.sh                    # Main installer
├── test.sh                     # Installation test
├── uninstall.sh               # Uninstaller
├── adminhub-cli.sh            # CLI interface
├── scripts/
│   ├── install_adminhub.sh    # Tool installation logic
│   ├── guest_setup_auto.sh    # Guest runtime setup
│   ├── setup/                 # Configuration scripts
│   └── utils/                 # Core utilities
│       ├── monitoring.sh      # Health checks & metrics
│       ├── config.sh          # Configuration management
│       ├── logging.sh         # Structured logging
│       ├── activate_tools.sh  # Manual tool activation
│       └── fix_homebrew_permissions.sh
├── launchagents/              # macOS LaunchAgents
└── CHANGELOG.md               # Version history
```

### System Integration
1. **Persistent Installation**: Tools in `/opt/admin-tools/`
2. **LaunchAgent**: `com.adminhub.guestsetup` auto-starts on Guest login
3. **Shell Integration**: Automatic PATH configuration via `.zshrc`
4. **Monitoring**: Continuous health checks and logging
5. **Self-Healing**: Automatic error recovery

### Logging System
- **5 Log Levels**: DEBUG, INFO, WARN, ERROR, FATAL
- **Separate Files**: Main, error, and guest-specific logs
- **Automatic Rotation**: Prevents disk space issues
- **Structured Format**: `[TIMESTAMP] [LEVEL] [SCRIPT] [USER] MESSAGE`

## 🐛 Troubleshooting

### Common Issues

#### Terminal doesn't open
```bash
# Check LaunchAgent status
./adminhub-cli.sh status

# Reload LaunchAgent
sudo launchctl unload /Library/LaunchAgents/com.adminhub.guestsetup.plist
sudo launchctl load /Library/LaunchAgents/com.adminhub.guestsetup.plist
```

#### Tools not available
```bash
# Check tool status
./adminhub-cli.sh tools test

# Manual activation (as Guest)
source /usr/local/bin/guest_setup_auto.sh
```

#### System health issues
```bash
# Run health check
./adminhub-cli.sh health detailed

# Auto-repair
./adminhub-cli.sh repair

# Check logs
./adminhub-cli.sh logs error
```

### Log Locations
```bash
# Main logs
/var/log/adminhub/adminhub.log      # General system logs
/var/log/adminhub/adminhub-error.log # Error logs
/var/log/adminhub/guest-setup.log   # Guest setup logs
/var/log/adminhub/alerts.log        # System alerts

# Legacy logs
/tmp/adminhub-setup.log             # Installation logs
/tmp/adminhub-setup.err             # Installation errors
```

### Emergency Recovery
```bash
# Complete reinstallation
sudo ./uninstall.sh
sudo ./setup.sh

# Check system integrity
./test.sh
```

## 📈 Performance & Monitoring

### System Metrics
AdminHub v2.0 tracks comprehensive metrics:

- **Tool Availability**: 7/7 tools working (100% success rate)
- **Setup Performance**: Guest setup time in seconds
- **System Health**: Overall status and component health
- **Error Tracking**: Automatic error counting and alerts
- **Uptime Monitoring**: System and service uptime tracking

### Integration Ready
```bash
# JSON status for monitoring systems
./adminhub-cli.sh status json

# Continuous monitoring
./adminhub-cli.sh monitor 300  # Check every 5 minutes

# Alert generation
./adminhub-cli.sh logs alerts
```

## 🤝 Contributing

This project was specifically developed for Lessing-Gymnasium Karlsruhe. For adaptations or extensions:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/NewFeature`)
3. Commit changes (`git commit -m 'Add NewFeature'`)
4. Push branch (`git push origin feature/NewFeature`)
5. Create Pull Request

## 📄 License

Copyright © 2025 Luka Löhr

This project is licensed under the MIT License with attribution. Any use must visibly include the copyright notice "© 2025 Luka Löhr".

See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

Developed for **Lessing-Gymnasium Karlsruhe** to support computer science education.

Special recognition for version 2.0 enterprise features that transform AdminHub from a simple tool installer into a comprehensive development environment management system.

## 📊 Version History

- **v2.0.1** (2025-07-02) - Bash 3.2 compatibility fixes
- **v2.0.0** (2025-07-02) - Enterprise features: CLI, monitoring, logging, configuration management
- **v1.0.0** (2025-01-18) - Initial release with basic tool automation

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

---

<p align="center">
  <strong>© 2025 Luka Löhr</strong><br>
  <a href="https://github.com/luka-loehr/AdminHub">github.com/luka-loehr/AdminHub</a>
</p> 
# AdminHub - Developer Tools for Guest Accounts 🎓

**Instantly provide coding tools to Guest users on macOS**

## What is AdminHub? 🤔

AdminHub lets teachers and IT admins install developer tools once, making them automatically available to all Guest users - no setup needed by students!

## Quick Start 🚀

### Prerequisites
- macOS with admin access
- [Homebrew](https://brew.sh) installed
- Guest account enabled

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
# Check system health (requires sudo)
sudo ./scripts/adminhub-cli.sh status

# View error logs
./scripts/adminhub-cli.sh logs error

# Uninstall
sudo ./scripts/adminhub-cli.sh uninstall
```

## Troubleshooting 🛠️

**Terminal doesn't open for Guest?**
- Check status: `sudo ./scripts/adminhub-cli.sh status`
- Reinstall if needed: `sudo ./scripts/adminhub-cli.sh install`

**Status shows "DEGRADED"?**
- Run with sudo: `sudo ./scripts/adminhub-cli.sh status`
- Without sudo, some checks can't run properly

**Need help?**
```bash
./scripts/adminhub-cli.sh --help
```

## How It Works 🔧

1. Admin installs tools to `/opt/admin-tools/`
2. LaunchAgent runs when Guest logs in
3. Tools are added to Guest's PATH automatically
4. Everything resets when Guest logs out

## License 📄

MIT License - © 2025 Luka Löhr

Created for Lessing-Gymnasium Karlsruhe to make coding education accessible.
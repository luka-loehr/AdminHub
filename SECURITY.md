# AdminHub Security Architecture

## Overview

AdminHub provides development tools to Guest users while maintaining strict security boundaries. This document explains the security model, design decisions, and why certain operations are blocked while others are allowed.

## The Challenge

In educational environments, we need to balance two competing requirements:
1. **Freedom to Learn**: Students should be able to experiment and install packages
2. **System Integrity**: Each student must get a clean, working environment

The key insight: **Not all package managers are created equal** when it comes to user isolation.

## Security Model

### Core Principle
All Guest user modifications must be:
- **Session-isolated**: Changes affect only the current user
- **Temporary**: Everything resets on logout
- **Non-destructive**: Cannot break tools for other users

### Why This Matters
Imagine a classroom scenario:
- Student A logs in at 9 AM, tries to install a package
- Student B logs in at 10 AM, expects working tools
- If Student A could modify system tools, Student B gets a broken environment

## Package Manager Security Analysis

### 🟢 Python/pip - User Isolation Supported

Python's pip has built-in support for user-specific installations:

```bash
pip install --user package_name
# Installs to ~/.local/lib/python3.x/site-packages/
```

**Why we allow it:**
- `--user` flag enables true isolation
- Packages install to user's home directory
- macOS automatically cleans Guest home on logout
- No risk to system Python or other users

**Our implementation:**
- Force `PIP_USER=1` environment variable
- Auto-add `--user` flag if missing
- Block system-wide flags like `--target /usr/local`

### 🔴 Homebrew - System-Wide Only

Homebrew does NOT support user-specific installations:

```bash
brew install package_name
# ALWAYS installs to /opt/homebrew/ (Apple Silicon) or /usr/local/ (Intel)
```

**Why we must block it:**
1. **No user isolation**: Homebrew has no `--user` equivalent
2. **Shared installation**: All users share the same Homebrew prefix
3. **Persistence**: Packages remain after Guest logout
4. **Dependency conflicts**: Student A installs node@16, Student B needs node@18
5. **Potential for damage**: `brew uninstall python` breaks AdminHub itself

**Real-world example:**
```bash
# Guest user runs:
brew install node
brew uninstall python
brew upgrade --force

# Result:
# - Node persists for all future users (unexpected tool)
# - Python is gone (AdminHub broken)
# - Random packages upgraded (compatibility issues)
```

### 🟡 NPM - Conditional Support

NPM supports both modes:
```bash
npm install package       # Local to project (allowed)
npm install -g package    # Global install (blocked)
```

**Our approach:**
- Allow local project installs
- Block `-g` (global) flag
- Set `NPM_CONFIG_PREFIX` to user directory

### 🟢 Git - Configuration Isolation

Git already separates user and system configuration:
```bash
git config --global   # User-specific (~/.gitconfig) ✓
git config --system   # System-wide (/etc/gitconfig) ✗
```

## Implementation Details

### Security Wrapper Architecture

```
/opt/admin-tools/
├── bin/              # Symlinks to wrappers
│   ├── brew -> ../wrappers/brew
│   ├── pip -> ../wrappers/pip
│   └── python -> ../wrappers/python
├── wrappers/         # Security wrapper scripts
│   ├── brew         # Blocks modifications
│   ├── pip          # Forces --user
│   └── python       # Sets secure environment
└── actual/bin/       # Real tool symlinks
    ├── brew -> /opt/homebrew/bin/brew
    ├── pip -> /opt/homebrew/bin/pip
    └── python -> /opt/homebrew/bin/python
```

### Brew Wrapper Logic

```bash
case "$1" in
    # Blocked: Modifications
    install|uninstall|upgrade|update|tap|untap|link|unlink)
        echo "❌ Error: System-wide modifications are not allowed"
        exit 1
        ;;
    # Allowed: Read-only operations
    list|info|search|doctor|config)
        exec "$ACTUAL_BREW" "$@"
        ;;
esac
```

### Pip Wrapper Logic

```bash
# Force user installation
export PIP_USER=1

# Auto-add --user flag
if [[ "$1" == "install" ]] && [[ "$*" != *"--user"* ]]; then
    set -- "$1" --user "${@:2}"
fi

exec "$ACTUAL_PIP" "$@"
```

## Alternative Approaches Considered

### 1. Separate Homebrew Instance per User
**Idea**: Install Homebrew to `~/.homebrew/` for each Guest

**Why rejected:**
- Homebrew hardcodes many paths at compile time
- Would need to compile bottles from source (slow)
- High disk usage (GB per user)
- Complex PATH management
- Potential conflicts with system Homebrew

### 2. Container/Sandbox Approach
**Idea**: Run each tool in an isolated container

**Why rejected:**
- Significant performance overhead
- Complex to implement on macOS
- Requires additional software
- Poor user experience (tools feel disconnected)

### 3. Allow Everything, Clean Later
**Idea**: Let Guest install anything, clean up on logout

**Why rejected:**
- Guest could break tools mid-session
- No way to prevent malicious changes
- Cleanup might fail or be incomplete
- Other users affected until cleanup runs

## Security Benefits

Our approach provides:

1. **Predictable Environment**: Every student gets identical tools
2. **No Accumulation**: System doesn't bloat over time
3. **Damage Prevention**: Students cannot break core tools
4. **Simple Mental Model**: "You can experiment, but only in your space"
5. **Zero Maintenance**: No manual cleanup needed

## Educational Advantages

This security model actually enhances learning:

1. **Safe Experimentation**: Students can try pip packages without fear
2. **Consistent Experience**: All students get the same environment
3. **Focus on Code**: No time wasted on broken environments
4. **Real-World Practice**: Mirrors corporate environments with restrictions

## Summary

The key insight is that **pip supports user isolation, but Homebrew does not**. By blocking Homebrew modifications while allowing pip user installs, we achieve the perfect balance:

- ✅ Students can install Python packages for their projects
- ✅ Each session starts fresh and clean
- ✅ No student can break tools for others
- ✅ System remains stable and predictable
- ✅ Zero maintenance required

This isn't a limitation—it's a feature that ensures every student gets a working environment every time.
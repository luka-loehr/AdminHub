# Deprecated Scripts

These scripts are kept for reference but should **not** be used anymore.

## Why deprecated?

These scripts use the old AppleScript-based approach which causes:
- Apple permission dialogs ("bash wants to control Terminal")
- Multiple Terminal windows opening
- Unreliable behavior

## Deprecated scripts:

- `open_guest_terminal.sh` - Uses AppleScript to open Terminal
- `guest_setup_final.sh` - Old setup script
- `simple_guest_setup.sh` - Previous simplified version
- `guest_setup_background.sh` - Background setup attempt
- `close_other_terminals.sh` - AppleScript terminal closer
- `open_terminal_at_login.sh` - Redundant, functionality now in guest_login_setup.sh
- `guest_shell_init.sh` - Old shell init script

## Current solution:

The new permission-free setup uses:
- LaunchAgent that runs at login
- Shell initialization (.zshrc/.bash_profile)
- No AppleScript = No permission dialogs! 
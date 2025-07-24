#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Setup pip configuration for Guest users
# Configures pip to allow package installation without breaking system packages

set -euo pipefail

# Source logging utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

# Function to create pip config for a user
create_pip_config() {
    local user_home="$1"
    local config_dir="$user_home/.config/pip"
    local config_file="$config_dir/pip.conf"
    
    log_info "Creating pip configuration for $user_home"
    
    # Create the directory if it doesn't exist
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        log_debug "Created pip config directory: $config_dir"
    fi
    
    # Create pip.conf with the necessary settings
    cat > "$config_file" << 'EOF'
[global]
break-system-packages = true
user = true
EOF
    
    # Set appropriate permissions
    chmod 644 "$config_file"
    
    log_info "Pip configuration created at: $config_file"
}

# Main function
setup_pip_config() {
    log_info "Setting up pip configuration..."
    
    # Setup for Guest user if directory exists
    if [[ -d "/Users/Guest" ]]; then
        create_pip_config "/Users/Guest"
    else
        log_debug "Guest home directory not found, skipping Guest pip config"
    fi
    
    # If running as sudo, also set up for the admin user
    if [[ -n "${SUDO_USER:-}" ]] && [[ "$SUDO_USER" != "root" ]]; then
        local admin_home=$(eval echo "~$SUDO_USER")
        if [[ -d "$admin_home" ]]; then
            create_pip_config "$admin_home"
        fi
    fi
    
    # Create a system-wide template that can be copied for new Guest sessions
    local template_dir="/opt/admin-tools/templates"
    mkdir -p "$template_dir/.config/pip"
    
    cat > "$template_dir/.config/pip/pip.conf" << 'EOF'
[global]
break-system-packages = true
user = true
EOF
    
    chmod -R 755 "$template_dir"
    chmod 644 "$template_dir/.config/pip/pip.conf"
    
    log_info "Pip configuration setup completed"
    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    setup_pip_config
fi
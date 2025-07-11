#!/bin/bash
# Homebrew repair utility for older Macs
# Ensures Homebrew is working before AdminHub installation

set -euo pipefail

# Source logging utility
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/logging.sh"

# Fix Homebrew installation issues on older Macs
fix_homebrew() {
    log_info "Checking Homebrew installation..."
    
    # Check if brew command exists
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not installed"
        return 1
    fi
    
    log_info "Detected Homebrew issues. Attempting automatic fix..."
    
    # Get Homebrew repository path
    local brew_repo=$(brew --repo 2>/dev/null || echo "/usr/local/Homebrew")
    
    # Update Homebrew repository
    log_debug "Updating Homebrew repository..."
    if [[ -d "$brew_repo/.git" ]]; then
        # Try to fetch and update
        if git -C "$brew_repo" fetch --unshallow 2>/dev/null; then
            log_debug "Fetched full Homebrew history"
        else
            git -C "$brew_repo" fetch 2>/dev/null || log_debug "Could not fetch updates"
        fi
        
        # Pull latest changes
        if git -C "$brew_repo" pull origin main 2>/dev/null; then
            log_debug "Updated to latest Homebrew"
        elif git -C "$brew_repo" pull origin master 2>/dev/null; then
            log_debug "Updated to latest Homebrew (master branch)"
        else
            log_debug "Could not pull latest changes"
        fi
    else
        log_debug "Homebrew repository not found at $brew_repo"
    fi
    
    # Fix common SSL issues with OpenSSL
    log_debug "Checking OpenSSL linking..."
    if brew link openssl 2>/dev/null; then
        log_debug "OpenSSL linked successfully"
    elif brew link --force openssl 2>/dev/null; then
        log_debug "OpenSSL force-linked successfully"
    else
        log_debug "Could not link OpenSSL"
    fi
    
    # Clean up old taps that might cause issues
    log_debug "Cleaning up old taps..."
    brew untap homebrew/core 2>/dev/null || true
    brew untap homebrew/science 2>/dev/null || true
    brew untap homebrew/python 2>/dev/null || true
    
    # Run cleanup to remove old versions and fix links
    log_debug "Running Homebrew cleanup..."
    brew cleanup --prune=all 2>/dev/null || log_debug "Cleanup completed with warnings"
    
    # Update Homebrew itself
    log_debug "Updating Homebrew..."
    if brew update 2>/dev/null; then
        log_info "Homebrew updated successfully"
    else
        log_debug "Homebrew update completed with warnings"
    fi
    
    # Fix permissions
    log_debug "Fixing Homebrew permissions..."
    local brew_prefix=$(brew --prefix 2>/dev/null || echo "/usr/local")
    local brew_dirs=(
        "$brew_prefix/bin"
        "$brew_prefix/lib"
        "$brew_prefix/share"
        "$brew_prefix/Homebrew"
        "$brew_prefix/Cellar"
        "$brew_prefix/opt"
    )
    
    for dir in "${brew_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            chmod -R o+rX "$dir" 2>/dev/null || log_debug "Could not fix permissions for $dir"
        fi
    done
    
    log_info "Homebrew fix attempt completed"
    return 0
}

# Check if Homebrew is healthy
check_homebrew_health() {
    log_info "Checking Homebrew health..."
    
    # Check if brew command exists
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not installed"
        return 1
    fi
    
    # Run brew doctor and capture output
    local doctor_output
    doctor_output=$(brew doctor 2>&1) || true
    
    if echo "$doctor_output" | grep -q "Your system is ready to brew"; then
        log_info "Homebrew is healthy"
        return 0
    elif echo "$doctor_output" | grep -q "Warning:"; then
        log_info "Homebrew has warnings but is functional"
        log_debug "Brew doctor output: $doctor_output"
        return 0
    else
        log_error "Homebrew has issues"
        log_debug "Brew doctor output: $doctor_output"
        return 1
    fi
}

# Main function to repair Homebrew
repair_homebrew() {
    log_info "Starting Homebrew repair process..."
    
    # First try to fix any issues
    if ! fix_homebrew; then
        log_error "Failed to fix Homebrew"
        return 1
    fi
    
    # Check if fixes were successful
    if check_homebrew_health; then
        log_info "Homebrew repair successful"
        return 0
    else
        log_error "Homebrew still has issues after repair attempt"
        return 1
    fi
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    repair_homebrew
fi
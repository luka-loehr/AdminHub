#!/bin/bash
# Copyright (c) 2025 Luka Löhr
#
# Homebrew repair utility - bulletproof version for all macOS configurations
# Handles Apple Silicon (/opt/homebrew) and Intel (/usr/local) installations
# Fixes permissions, symlinks, dependencies, and Python/OpenSSL issues
# Enhanced with support for old Macs (4+ years without updates)

set -euo pipefail

# Source logging utility
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/logging.sh"

# Source compatibility checker for version comparison
if [[ -f "${SCRIPT_DIR}/old_mac_compatibility.sh" ]]; then
    source "${SCRIPT_DIR}/old_mac_compatibility.sh"
fi

# Global variables for output
BREW_PREFIX=""
PYTHON_VERSION=""
PYTHON_LIBEXEC_DIR=""
ORIGINAL_USER=""
ORIGINAL_UID=""
ORIGINAL_GID=""

# Detect the actual user when running as sudo
detect_original_user() {
    if [[ "$EUID" -eq 0 ]] && [[ -n "${SUDO_USER:-}" ]]; then
        ORIGINAL_USER="$SUDO_USER"
        ORIGINAL_UID="$(id -u "$SUDO_USER")"
        ORIGINAL_GID="$(id -g "$SUDO_USER")"
        log_debug "Detected original user: $ORIGINAL_USER (UID: $ORIGINAL_UID, GID: $ORIGINAL_GID)"
    else
        ORIGINAL_USER="$(whoami)"
        ORIGINAL_UID="$(id -u)"
        ORIGINAL_GID="$(id -g)"
        log_debug "Running as user: $ORIGINAL_USER (UID: $ORIGINAL_UID, GID: $ORIGINAL_GID)"
    fi
}

# Run command as the original user, not root
run_as_user() {
    if [[ "$EUID" -eq 0 ]] && [[ -n "$ORIGINAL_USER" ]] && [[ "$ORIGINAL_USER" != "root" ]]; then
        sudo -u "$ORIGINAL_USER" "$@"
    else
        "$@"
    fi
}

# Check Ruby version compatibility
check_ruby_compatibility() {
    log_info "Checking Ruby version for Homebrew compatibility..."
    
    if ! command -v ruby &>/dev/null; then
        log_error "Ruby not found - this should not happen on macOS"
        return 1
    fi
    
    local ruby_version=$(ruby -e 'puts RUBY_VERSION' 2>/dev/null || echo "0.0.0")
    log_debug "System Ruby version: $ruby_version"
    
    # Homebrew requires Ruby 2.6+
    if declare -f version_compare >/dev/null 2>&1; then
        if [[ $(version_compare "$ruby_version" "2.6.0") -eq -1 ]]; then
            log_warn "Ruby $ruby_version is too old for modern Homebrew (requires 2.6+)"
            log_info "Setting HOMEBREW_FORCE_VENDOR_RUBY to use portable Ruby"
            export HOMEBREW_FORCE_VENDOR_RUBY=1
            return 2
        fi
    else
        # Fallback check without version_compare
        local major=$(echo "$ruby_version" | cut -d. -f1)
        local minor=$(echo "$ruby_version" | cut -d. -f2)
        if [[ $major -lt 2 ]] || [[ $major -eq 2 && $minor -lt 6 ]]; then
            log_warn "Ruby $ruby_version may be too old for Homebrew"
            export HOMEBREW_FORCE_VENDOR_RUBY=1
            return 2
        fi
    fi
    
    return 0
}

# Clean up legacy Homebrew installations
cleanup_legacy_homebrew() {
    log_info "Checking for legacy Homebrew installations..."
    
    local legacy_found=false
    local legacy_dirs=()
    
    # Check for very old Homebrew structure
    if [[ "$BREW_PREFIX" == "/usr/local" ]]; then
        # Old Homebrew used to put everything directly in /usr/local
        local old_indicators=(
            "/usr/local/Library/brew.rb"
            "/usr/local/Library/Homebrew/brew.rb"
            "/usr/local/.git"
        )
        
        for indicator in "${old_indicators[@]}"; do
            if [[ -e "$indicator" ]]; then
                log_warn "Found legacy Homebrew indicator: $indicator"
                legacy_found=true
                legacy_dirs+=("$indicator")
            fi
        done
    fi
    
    # Check for abandoned Homebrew directories
    local abandoned_dirs=(
        "/usr/local/Homebrew.old"
        "/usr/local/Library/Taps/homebrew/homebrew-php"
        "/usr/local/Library/Taps/homebrew/homebrew-apache"
        "/usr/local/Library/Taps/homebrew/homebrew-dupes"
        "/usr/local/Library/Taps/homebrew/homebrew-versions"
    )
    
    for dir in "${abandoned_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_warn "Found abandoned Homebrew directory: $dir"
            legacy_found=true
            legacy_dirs+=("$dir")
        fi
    done
    
    if [[ "$legacy_found" == "true" ]]; then
        log_warn "Legacy Homebrew files detected. Consider backing up and removing:"
        for dir in "${legacy_dirs[@]}"; do
            log_warn "  - $dir"
        done
        
        # Don't auto-remove, just warn
        log_info "After backing up, you can remove these with:"
        log_info "  sudo rm -rf ${legacy_dirs[*]}"
    else
        log_info "No legacy Homebrew installations found"
    fi
    
    return 0
}

# Auto-detect Homebrew installation location
detect_homebrew_prefix() {
    log_info "Auto-detecting Homebrew installation location..."
    
    # Check common locations in order of preference
    local possible_prefixes=(
        "/opt/homebrew"           # Apple Silicon default
        "/usr/local"              # Intel default
        "/usr/local/Homebrew"     # Alternative Intel location
    )
    
    for prefix in "${possible_prefixes[@]}"; do
        if [[ -x "$prefix/bin/brew" ]]; then
            BREW_PREFIX="$prefix"
            log_info "Found Homebrew at: $BREW_PREFIX"
            
            # Check if this is a legacy installation
            cleanup_legacy_homebrew
            
            return 0
        fi
    done
    
    # Try to get from brew command if available
    if command -v brew &> /dev/null; then
        BREW_PREFIX="$(brew --prefix 2>/dev/null)" || true
        if [[ -n "$BREW_PREFIX" ]]; then
            log_info "Detected Homebrew prefix from brew command: $BREW_PREFIX"
            return 0
        fi
    fi
    
    log_error "Could not detect Homebrew installation"
    return 1
}

# Create missing directories with proper permissions
create_missing_directories() {
    log_info "Creating missing Homebrew directories..."
    
    local directories=(
        "$BREW_PREFIX/bin"
        "$BREW_PREFIX/lib"
        "$BREW_PREFIX/share"
        "$BREW_PREFIX/opt"
        "$BREW_PREFIX/Cellar"
        "$BREW_PREFIX/Caskroom"
        "$BREW_PREFIX/Frameworks"
        "$BREW_PREFIX/include"
        "$BREW_PREFIX/sbin"
        "$BREW_PREFIX/var"
        "$BREW_PREFIX/etc"
    )
    
    # Special handling for /usr/local/Frameworks
    if [[ "$BREW_PREFIX" == "/usr/local" ]]; then
        directories+=("/usr/local/Frameworks")
    fi
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_debug "Creating directory: $dir"
            mkdir -p "$dir" 2>/dev/null || {
                log_debug "Could not create $dir, trying with sudo"
                sudo mkdir -p "$dir" 2>/dev/null || log_debug "Failed to create $dir"
            }
        fi
    done
}

# Fix ownership and permissions for all Homebrew directories
fix_permissions() {
    log_info "Fixing Homebrew directory permissions..."
    
    # Directories that need to be writable by the user
    local user_writable_dirs=(
        "$BREW_PREFIX/bin"
        "$BREW_PREFIX/lib"
        "$BREW_PREFIX/share"
        "$BREW_PREFIX/opt"
        "$BREW_PREFIX/Cellar"
        "$BREW_PREFIX/Caskroom"
        "$BREW_PREFIX/Frameworks"
        "$BREW_PREFIX/include"
        "$BREW_PREFIX/sbin"
        "$BREW_PREFIX/var"
        "$BREW_PREFIX/etc"
        "$BREW_PREFIX/Homebrew"
    )
    
    # Fix ownership to original user
    for dir in "${user_writable_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_debug "Fixing ownership for: $dir"
            if [[ "$EUID" -eq 0 ]]; then
                chown -R "$ORIGINAL_USER:$ORIGINAL_GID" "$dir" 2>/dev/null || \
                    log_debug "Could not change ownership of $dir"
            fi
            # Make readable by all users
            chmod -R a+rX "$dir" 2>/dev/null || \
                log_debug "Could not fix permissions for $dir"
        fi
    done
    
    # Special handling for /usr/local on Intel Macs
    if [[ "$BREW_PREFIX" == "/usr/local" ]]; then
        # Ensure /usr/local itself is accessible
        chmod 755 /usr/local 2>/dev/null || log_debug "Could not chmod /usr/local"
    fi
}

# Clean up broken symlinks
cleanup_broken_symlinks() {
    log_info "Cleaning up broken symbolic links..."
    
    local link_dirs=(
        "$BREW_PREFIX/bin"
        "$BREW_PREFIX/sbin"
        "$BREW_PREFIX/lib"
        "$BREW_PREFIX/include"
    )
    
    local total_cleaned=0
    
    for dir in "${link_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_debug "Checking for broken symlinks in: $dir"
            while IFS= read -r -d '' broken_link; do
                log_debug "Removing broken symlink: $broken_link"
                rm -f "$broken_link" 2>/dev/null || \
                    sudo rm -f "$broken_link" 2>/dev/null || \
                    log_debug "Could not remove: $broken_link"
                ((total_cleaned++))
            done < <(find "$dir" -type l ! -exec test -e {} \; -print0 2>/dev/null)
        fi
    done
    
    log_info "Cleaned up $total_cleaned broken symlinks"
}

# Update and fix Homebrew repository
update_homebrew_repo() {
    log_info "Updating Homebrew repository..."
    
    local brew_repo="$BREW_PREFIX/Homebrew"
    if [[ ! -d "$brew_repo/.git" ]]; then
        brew_repo="$(run_as_user brew --repo 2>/dev/null)" || brew_repo="$BREW_PREFIX"
    fi
    
    if [[ -d "$brew_repo/.git" ]]; then
        log_debug "Found Homebrew git repository at: $brew_repo"
        
        # Reset any local changes
        run_as_user git -C "$brew_repo" reset --hard 2>/dev/null || \
            log_debug "Could not reset repository"
        
        # Fetch updates
        if run_as_user git -C "$brew_repo" fetch --unshallow 2>/dev/null; then
            log_debug "Fetched full Homebrew history"
        else
            run_as_user git -C "$brew_repo" fetch 2>/dev/null || \
                log_debug "Could not fetch updates"
        fi
        
        # Pull latest changes
        if run_as_user git -C "$brew_repo" pull origin main 2>/dev/null; then
            log_debug "Updated to latest Homebrew (main branch)"
        elif run_as_user git -C "$brew_repo" pull origin master 2>/dev/null; then
            log_debug "Updated to latest Homebrew (master branch)"
        else
            log_debug "Could not pull latest changes"
        fi
    fi
}

# Clean up problematic taps
cleanup_old_taps() {
    log_info "Cleaning up old and problematic taps..."
    
    local problematic_taps=(
        "homebrew/core"
        "homebrew/science"
        "homebrew/python"
        "homebrew/dupes"
        "homebrew/versions"
    )
    
    for tap in "${problematic_taps[@]}"; do
        if run_as_user brew tap | grep -q "^$tap\$"; then
            log_debug "Removing tap: $tap"
            run_as_user brew untap "$tap" 2>/dev/null || true
        fi
    done
}

# Fix OpenSSL conflicts and linking
fix_openssl() {
    log_info "Resolving OpenSSL conflicts..."
    
    # Unlink all OpenSSL versions first
    for formula in openssl openssl@3 openssl@1.1; do
        if run_as_user brew list "$formula" &>/dev/null; then
            run_as_user brew unlink "$formula" 2>/dev/null || true
        fi
    done
    
    # Link the latest OpenSSL version
    if run_as_user brew list openssl@3 &>/dev/null; then
        log_debug "Linking openssl@3"
        run_as_user brew link --force --overwrite openssl@3 2>/dev/null || \
            log_debug "Could not force link openssl@3"
    elif run_as_user brew list openssl &>/dev/null; then
        log_debug "Linking openssl"
        run_as_user brew link --force --overwrite openssl 2>/dev/null || \
            log_debug "Could not force link openssl"
    fi
    
    # Ensure ca-certificates is installed
    if ! run_as_user brew list ca-certificates &>/dev/null; then
        log_debug "Installing ca-certificates"
        run_as_user brew install ca-certificates 2>/dev/null || \
            log_debug "Could not install ca-certificates"
    fi
}

# Install missing dependencies
install_missing_dependencies() {
    log_info "Checking and installing missing dependencies..."
    
    # Get list of missing dependencies
    local missing_deps
    missing_deps=$(run_as_user brew missing 2>/dev/null | grep -v "^Warning:" | sort | uniq) || true
    
    if [[ -n "$missing_deps" ]]; then
        log_debug "Found missing dependencies: $missing_deps"
        while IFS= read -r dep; do
            if [[ -n "$dep" ]]; then
                log_debug "Installing missing dependency: $dep"
                run_as_user brew install "$dep" 2>/dev/null || \
                    log_debug "Could not install $dep"
            fi
        done <<< "$missing_deps"
    fi
    
    # Common dependencies that should be installed
    local essential_deps=(
        "ca-certificates"
        "mpdecimal"
        "sqlite"
        "xz"
    )
    
    for dep in "${essential_deps[@]}"; do
        if ! run_as_user brew list "$dep" &>/dev/null; then
            log_debug "Installing essential dependency: $dep"
            run_as_user brew install "$dep" 2>/dev/null || \
                log_debug "Could not install $dep"
        fi
    done
}

# Fix Python installation and create unversioned symlinks
fix_python() {
    log_info "Fixing Python installation and symlinks..."
    
    # First ensure Python is installed
    if ! run_as_user brew list python@3 &>/dev/null && ! run_as_user brew list python &>/dev/null; then
        log_debug "Installing Python..."
        run_as_user brew install python@3 2>/dev/null || \
            run_as_user brew install python 2>/dev/null || \
            log_error "Could not install Python"
    fi
    
    # Find the latest Python version installed
    local python_versions=()
    while IFS= read -r version; do
        python_versions+=("$version")
    done < <(run_as_user brew list | grep -E '^python(@[0-9.]+)?$' | sort -V)
    
    if [[ ${#python_versions[@]} -eq 0 ]]; then
        log_error "No Python installation found"
        return 1
    fi
    
    # Use the latest version
    local latest_python="${python_versions[-1]}"
    log_debug "Latest Python formula: $latest_python"
    
    # Get Python version number
    if [[ "$latest_python" =~ python@([0-9]+\.[0-9]+) ]]; then
        PYTHON_VERSION="${BASH_REMATCH[1]}"
    else
        # Try to get version from python executable
        PYTHON_VERSION=$(run_as_user "$BREW_PREFIX/bin/python3" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+') || "3.12"
    fi
    
    log_debug "Python version: $PYTHON_VERSION"
    
    # Find libexec directory
    PYTHON_LIBEXEC_DIR="$BREW_PREFIX/opt/$latest_python/libexec/bin"
    if [[ ! -d "$PYTHON_LIBEXEC_DIR" ]]; then
        PYTHON_LIBEXEC_DIR="$BREW_PREFIX/opt/python@$PYTHON_VERSION/libexec/bin"
    fi
    if [[ ! -d "$PYTHON_LIBEXEC_DIR" ]]; then
        PYTHON_LIBEXEC_DIR="$BREW_PREFIX/opt/python/libexec/bin"
    fi
    
    log_debug "Python libexec directory: $PYTHON_LIBEXEC_DIR"
    
    # Create unversioned symlinks
    if [[ -d "$PYTHON_LIBEXEC_DIR" ]]; then
        # Remove old/broken Python symlinks first
        rm -f "$BREW_PREFIX/bin/python" 2>/dev/null || true
        rm -f "$BREW_PREFIX/bin/pip" 2>/dev/null || true
        
        # Create new symlinks
        if [[ -x "$PYTHON_LIBEXEC_DIR/python" ]]; then
            ln -sf "$PYTHON_LIBEXEC_DIR/python" "$BREW_PREFIX/bin/python" 2>/dev/null || \
                log_debug "Could not create python symlink"
        fi
        
        if [[ -x "$PYTHON_LIBEXEC_DIR/pip" ]]; then
            ln -sf "$PYTHON_LIBEXEC_DIR/pip" "$BREW_PREFIX/bin/pip" 2>/dev/null || \
                log_debug "Could not create pip symlink"
        fi
    else
        # Fallback: create symlinks to versioned commands
        if [[ -x "$BREW_PREFIX/bin/python3" ]]; then
            ln -sf "$BREW_PREFIX/bin/python3" "$BREW_PREFIX/bin/python" 2>/dev/null || true
        fi
        if [[ -x "$BREW_PREFIX/bin/pip3" ]]; then
            ln -sf "$BREW_PREFIX/bin/pip3" "$BREW_PREFIX/bin/pip" 2>/dev/null || true
        fi
    fi
}

# Run comprehensive Homebrew cleanup
run_cleanup() {
    log_info "Running Homebrew cleanup..."
    
    # Remove old versions
    run_as_user brew cleanup --prune=all 2>/dev/null || \
        log_debug "Cleanup completed with warnings"
    
    # Remove cache
    rm -rf "$(run_as_user brew --cache)" 2>/dev/null || true
}

# Update Homebrew and formulae
update_homebrew() {
    log_info "Updating Homebrew..."
    
    # Update Homebrew itself
    if run_as_user brew update 2>/dev/null; then
        log_info "Homebrew updated successfully"
    else
        log_debug "Homebrew update completed with warnings"
    fi
    
    # Upgrade all formulae
    log_debug "Upgrading formulae..."
    run_as_user brew upgrade 2>/dev/null || \
        log_debug "Some formulae could not be upgraded"
}

# Check Homebrew health
check_homebrew_health() {
    log_info "Checking Homebrew health..."
    
    # Run brew doctor and analyze output
    local doctor_output
    doctor_output=$(run_as_user brew doctor 2>&1) || true
    
    if echo "$doctor_output" | grep -q "Your system is ready to brew"; then
        log_info "Homebrew is healthy"
        return 0
    else
        log_info "Homebrew has some warnings but should be functional"
        log_debug "Brew doctor output: $doctor_output"
        # Still return success as warnings are often non-critical
        return 0
    fi
}

# Output important variables for other scripts
output_variables() {
    log_info "Outputting configuration variables..."
    
    echo "# Homebrew configuration (generated by homebrew_repair.sh)"
    echo "export BREW_PREFIX=\"$BREW_PREFIX\""
    echo "export PYTHON_VERSION=\"$PYTHON_VERSION\""
    echo "export PYTHON_LIBEXEC_DIR=\"$PYTHON_LIBEXEC_DIR\""
    echo ""
    echo "# Add to PATH if needed:"
    echo "export PATH=\"$BREW_PREFIX/bin:$BREW_PREFIX/sbin:\$PATH\""
    if [[ -n "$PYTHON_LIBEXEC_DIR" ]] && [[ -d "$PYTHON_LIBEXEC_DIR" ]]; then
        echo "export PATH=\"$PYTHON_LIBEXEC_DIR:\$PATH\""
    fi
}

# Fix Python 2 compatibility for old systems
fix_python2_compatibility() {
    log_info "Checking Python 2 compatibility for legacy tools..."
    
    # Some old tools still require python2
    if ! command -v python2 &>/dev/null; then
        # Check if python2.7 exists
        if command -v python2.7 &>/dev/null; then
            log_info "Creating python2 symlink to python2.7"
            ln -sf "$(which python2.7)" "$BREW_PREFIX/bin/python2" 2>/dev/null || \
                log_debug "Could not create python2 symlink"
        elif [[ -x "/usr/bin/python2.7" ]]; then
            log_info "Creating python2 symlink to system python2.7"
            ln -sf "/usr/bin/python2.7" "$BREW_PREFIX/bin/python2" 2>/dev/null || \
                log_debug "Could not create python2 symlink"
        else
            log_debug "No Python 2.7 found for compatibility layer"
        fi
    fi
    
    return 0
}

# Handle very old Homebrew versions
handle_old_homebrew_version() {
    log_info "Checking Homebrew version compatibility..."
    
    local brew_version=$(run_as_user brew --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "0.0")
    log_debug "Homebrew version: $brew_version"
    
    # Check if Homebrew is very old (< 2.0)
    if declare -f version_compare >/dev/null 2>&1; then
        if [[ $(version_compare "$brew_version" "2.0") -eq -1 ]]; then
            log_warn "Very old Homebrew version detected: $brew_version"
            log_warn "Consider updating Homebrew itself first"
            
            # Set compatibility environment
            export HOMEBREW_NO_AUTO_UPDATE=1
            export HOMEBREW_NO_ANALYTICS=1
            export HOMEBREW_NO_GITHUB_API=1
        fi
    fi
    
    return 0
}

# Main repair function
repair_homebrew() {
    log_info "Starting comprehensive Homebrew repair..."
    
    # Detect original user
    detect_original_user
    
    # Check Ruby compatibility first
    check_ruby_compatibility
    
    # Detect Homebrew location
    if ! detect_homebrew_prefix; then
        log_error "Cannot proceed without Homebrew installation"
        return 1
    fi
    
    # Ensure brew command is in PATH
    export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
    
    # Handle old Homebrew versions
    handle_old_homebrew_version
    
    # Create missing directories
    create_missing_directories
    
    # Fix permissions first
    fix_permissions
    
    # Clean broken symlinks
    cleanup_broken_symlinks
    
    # Update Homebrew repository
    update_homebrew_repo
    
    # Clean problematic taps
    cleanup_old_taps
    
    # Run initial cleanup
    run_cleanup
    
    # Update Homebrew
    update_homebrew
    
    # Fix OpenSSL
    fix_openssl
    
    # Install missing dependencies
    install_missing_dependencies
    
    # Fix Python
    fix_python
    
    # Fix Python 2 compatibility
    fix_python2_compatibility
    
    # Final cleanup
    run_cleanup
    
    # Check health
    check_homebrew_health
    
    # Output variables
    output_variables
    
    log_info "Homebrew repair completed successfully"
    return 0
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    repair_homebrew
fi
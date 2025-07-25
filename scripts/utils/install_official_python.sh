#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Official Python Installer for AdminHub
# Downloads and installs Python from python.org

set -euo pipefail

# Source logging utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

# Function to get latest Python version
get_latest_python_version() {
    log_info "Fetching latest Python version from python.org..."
    
    # Fetch the downloads page and extract version numbers
    local versions_html=$(curl -s "https://www.python.org/downloads/" 2>/dev/null || echo "")
    
    if [[ -z "$versions_html" ]]; then
        log_error "Failed to fetch Python versions from python.org"
        return 1
    fi
    
    # Extract version numbers from download links (looking for stable releases)
    # Pattern matches versions like 3.13.5, 3.12.8, etc.
    local latest_version=$(echo "$versions_html" | \
        grep -oE 'Python [0-9]+\.[0-9]+\.[0-9]+' | \
        grep -v 'rc\|a\|b' | \
        sed 's/Python //' | \
        sort -V | \
        tail -1)
    
    if [[ -z "$latest_version" ]]; then
        log_error "Could not determine latest Python version"
        return 1
    fi
    
    echo "$latest_version"
    return 0
}

# Get latest version
PYTHON_VERSION=$(get_latest_python_version)
if [[ -z "$PYTHON_VERSION" ]]; then
    # Fallback to a known good version
    log_warn "Using fallback Python version 3.13.5"
    PYTHON_VERSION="3.13.5"
fi

# Extract major.minor version for paths
PYTHON_MAJOR_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f1,2)

# Configuration
PYTHON_PKG_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-macos11.pkg"
PYTHON_PKG_FILE="/tmp/python-${PYTHON_VERSION}-macos11.pkg"
PYTHON_INSTALL_PATH="/Library/Frameworks/Python.framework/Versions/${PYTHON_MAJOR_MINOR}"
PYTHON_BIN_PATH="${PYTHON_INSTALL_PATH}/bin"

# Function to find any official Python installation
find_official_python() {
    # Check for any Python version in the Frameworks directory
    local framework_base="/Library/Frameworks/Python.framework/Versions"
    if [[ -d "$framework_base" ]]; then
        # Find the highest installed version
        local installed_version=$(ls -1 "$framework_base" | grep -E '^[0-9]+\.[0-9]+$' | sort -V | tail -1)
        if [[ -n "$installed_version" ]]; then
            echo "$installed_version"
            return 0
        fi
    fi
    return 1
}

# Function to check if official Python is already installed
check_official_python() {
    local existing_version=$(find_official_python)
    if [[ -n "$existing_version" ]]; then
        local existing_path="/Library/Frameworks/Python.framework/Versions/$existing_version"
        if [[ -x "$existing_path/bin/python3" ]]; then
            local installed_full_version=$("$existing_path/bin/python3" --version 2>&1 | cut -d' ' -f2)
            log_info "Official Python ${installed_full_version} is already installed"
            
            # Update our paths to use the existing installation
            PYTHON_MAJOR_MINOR="$existing_version"
            PYTHON_INSTALL_PATH="$existing_path"
            PYTHON_BIN_PATH="${PYTHON_INSTALL_PATH}/bin"
            
            # Check if it's the latest version
            if [[ "$installed_full_version" == "$PYTHON_VERSION" ]]; then
                log_info "Already have the latest version"
                return 0
            else
                log_info "Newer version $PYTHON_VERSION is available (current: $installed_full_version)"
                return 1
            fi
        fi
    fi
    return 1
}

# Function to download Python installer
download_python() {
    log_info "Downloading Python ${PYTHON_VERSION} from python.org..."
    
    if [ -f "$PYTHON_PKG_FILE" ]; then
        log_info "Python installer already downloaded"
        return 0
    fi
    
    # Download the installer
    if command -v curl &> /dev/null; then
        curl -L -o "$PYTHON_PKG_FILE" "$PYTHON_PKG_URL" || {
            log_error "Failed to download Python installer"
            return 1
        }
    else
        log_error "curl not found. Cannot download Python installer"
        return 1
    fi
    
    log_info "Python installer downloaded successfully"
    return 0
}

# Function to install Python
install_python() {
    log_info "Installing Python ${PYTHON_VERSION}..."
    
    # Verify the downloaded file exists
    if [ ! -f "$PYTHON_PKG_FILE" ]; then
        log_error "Python installer not found at $PYTHON_PKG_FILE"
        return 1
    fi
    
    # Install the package
    installer -pkg "$PYTHON_PKG_FILE" -target / || {
        log_error "Failed to install Python"
        return 1
    }
    
    # Clean up installer
    rm -f "$PYTHON_PKG_FILE"
    
    # Verify installation
    if [ -x "${PYTHON_BIN_PATH}/python3" ]; then
        local installed_version=$("${PYTHON_BIN_PATH}/python3" --version 2>&1 | cut -d' ' -f2)
        log_info "Python ${installed_version} installed successfully"
        
        # Ensure pip is upgraded
        "${PYTHON_BIN_PATH}/python3" -m pip install --upgrade pip &>/dev/null || true
        
        return 0
    else
        log_error "Python installation verification failed"
        return 1
    fi
}

# Function to create unversioned symlinks
create_python_symlinks() {
    log_info "Creating Python symlinks..."
    
    # Ensure the bin directory exists
    if [ ! -d "${PYTHON_BIN_PATH}" ]; then
        log_error "Python bin directory not found at ${PYTHON_BIN_PATH}"
        return 1
    fi
    
    # Create unversioned symlinks in the Python bin directory
    if [ -x "${PYTHON_BIN_PATH}/python3" ] && [ ! -e "${PYTHON_BIN_PATH}/python" ]; then
        ln -sf "${PYTHON_BIN_PATH}/python3" "${PYTHON_BIN_PATH}/python"
        log_info "Created python -> python3 symlink"
    fi
    
    if [ -x "${PYTHON_BIN_PATH}/pip3" ] && [ ! -e "${PYTHON_BIN_PATH}/pip" ]; then
        ln -sf "${PYTHON_BIN_PATH}/pip3" "${PYTHON_BIN_PATH}/pip"
        log_info "Created pip -> pip3 symlink"
    fi
    
    return 0
}

# Main installation function
install_official_python() {
    log_info "Starting official Python installation process..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run with sudo"
        return 1
    fi
    
    # Check if official Python is already installed
    if check_official_python; then
        log_info "Official Python is already installed. Creating symlinks if needed..."
        create_python_symlinks
        return 0
    fi
    
    # Download Python installer
    if ! download_python; then
        return 1
    fi
    
    # Install Python
    if ! install_python; then
        return 1
    fi
    
    # Create symlinks
    create_python_symlinks
    
    log_info "Official Python installation completed successfully"
    return 0
}

# Function to get Python paths for symlink creation
get_python_paths() {
    # Try to find the actual installation
    local actual_version=$(find_official_python)
    if [[ -n "$actual_version" ]]; then
        local actual_bin="/Library/Frameworks/Python.framework/Versions/$actual_version/bin"
        echo "PYTHON_PATH=${actual_bin}/python"
        echo "PYTHON3_PATH=${actual_bin}/python3"
        echo "PIP_PATH=${actual_bin}/pip"
        echo "PIP3_PATH=${actual_bin}/pip3"
        echo "PYTHON_VERSION=$actual_version"
    else
        echo "PYTHON_PATH=${PYTHON_BIN_PATH}/python"
        echo "PYTHON3_PATH=${PYTHON_BIN_PATH}/python3"
        echo "PIP_PATH=${PYTHON_BIN_PATH}/pip"
        echo "PIP3_PATH=${PYTHON_BIN_PATH}/pip3"
        echo "PYTHON_VERSION=$PYTHON_MAJOR_MINOR"
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    install_official_python
fi
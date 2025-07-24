#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Official Python Installer for AdminHub
# Downloads and installs Python from python.org

set -euo pipefail

# Source logging utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

# Configuration
PYTHON_VERSION="3.13.5"
PYTHON_PKG_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-macos11.pkg"
PYTHON_PKG_FILE="/tmp/python-${PYTHON_VERSION}-macos11.pkg"
PYTHON_INSTALL_PATH="/Library/Frameworks/Python.framework/Versions/3.13"
PYTHON_BIN_PATH="${PYTHON_INSTALL_PATH}/bin"

# Function to check if official Python is already installed
check_official_python() {
    if [ -d "$PYTHON_INSTALL_PATH" ] && [ -x "${PYTHON_BIN_PATH}/python3" ]; then
        local installed_version=$("${PYTHON_BIN_PATH}/python3" --version 2>&1 | cut -d' ' -f2)
        log_info "Official Python ${installed_version} is already installed"
        return 0
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
    echo "PYTHON_PATH=${PYTHON_BIN_PATH}/python"
    echo "PYTHON3_PATH=${PYTHON_BIN_PATH}/python3"
    echo "PIP_PATH=${PYTHON_BIN_PATH}/pip"
    echo "PIP3_PATH=${PYTHON_BIN_PATH}/pip3"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    install_official_python
fi
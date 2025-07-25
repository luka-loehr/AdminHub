#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Python utilities for AdminHub
# Functions to detect and work with official Python installations

# Function to find the installed official Python version
find_official_python_version() {
    local framework_base="/Library/Frameworks/Python.framework/Versions"
    if [[ -d "$framework_base" ]]; then
        # Find the highest installed version
        local version=$(ls -1 "$framework_base" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+$' | sort -V | tail -1)
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi
    return 1
}

# Function to get Python bin directory
get_python_bin_dir() {
    local version=$(find_official_python_version)
    if [[ -n "$version" ]]; then
        echo "/Library/Frameworks/Python.framework/Versions/$version/bin"
        return 0
    fi
    return 1
}

# Export functions for use in other scripts
export -f find_official_python_version
export -f get_python_bin_dir
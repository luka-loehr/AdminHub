#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub System Monitoring and Health Check Utility (Bash 3.2 Compatible)
# Provides comprehensive monitoring of AdminHub components and tools

# Source dependencies
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
[[ -f "$SCRIPT_DIR/logging.sh" ]] && source "$SCRIPT_DIR/logging.sh"
[[ -f "$SCRIPT_DIR/config.sh" ]] && source "$SCRIPT_DIR/config.sh"

# Monitoring configuration
HEALTH_CHECK_FILE="/var/log/adminhub/health-status.json"
METRICS_FILE="/var/log/adminhub/metrics.json"
ALERTS_FILE="/var/log/adminhub/alerts.log"

# Health check status variables (bash 3.2 compatible)
HEALTH_OVERALL="unknown"
HEALTH_ADMIN_TOOLS="unknown"
HEALTH_GUEST_SETUP="unknown"
HEALTH_LAUNCHAGENT="unknown"
HEALTH_HOMEBREW="unknown"
HEALTH_PERMISSIONS="unknown"
HEALTH_DISK_SPACE="unknown"

# Performance metrics variables
METRICS_SETUP_TIME="0"
METRICS_TOOL_COUNT="0"
METRICS_ERROR_COUNT="0"
METRICS_GUEST_LOGINS="0"
METRICS_LAST_CHECK="never"

# Function to convert to uppercase (bash 3.2 compatible)
to_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Function to set health status
set_health_status() {
    local component="$1"
    local status="$2"
    
    case "$component" in
        "overall") HEALTH_OVERALL="$status" ;;
        "admin_tools") HEALTH_ADMIN_TOOLS="$status" ;;
        "guest_setup") HEALTH_GUEST_SETUP="$status" ;;
        "launchagent") HEALTH_LAUNCHAGENT="$status" ;;
        "homebrew") HEALTH_HOMEBREW="$status" ;;
        "permissions") HEALTH_PERMISSIONS="$status" ;;
        "disk_space") HEALTH_DISK_SPACE="$status" ;;
    esac
}

# Function to get health status
get_health_status() {
    local component="$1"
    
    case "$component" in
        "overall") echo "$HEALTH_OVERALL" ;;
        "admin_tools") echo "$HEALTH_ADMIN_TOOLS" ;;
        "guest_setup") echo "$HEALTH_GUEST_SETUP" ;;
        "launchagent") echo "$HEALTH_LAUNCHAGENT" ;;
        "homebrew") echo "$HEALTH_HOMEBREW" ;;
        "permissions") echo "$HEALTH_PERMISSIONS" ;;
        "disk_space") echo "$HEALTH_DISK_SPACE" ;;
        *) echo "unknown" ;;
    esac
}

# Function to get status color
get_status_color() {
    case "$1" in
        "healthy") echo '\033[0;32m' ;;
        "degraded") echo '\033[1;33m' ;;
        "unhealthy") echo '\033[0;31m' ;;
        "unknown") echo '\033[0;37m' ;;
        *) echo '\033[0m' ;;
    esac
}

# Function to get system uptime
get_uptime() {
    local uptime_seconds=$(sysctl -n kern.boottime 2>/dev/null | awk '{print $4}' | sed 's/,//')
    local current_time=$(date +%s)
    local uptime=$((current_time - uptime_seconds))
    
    local days=$((uptime / 86400))
    local hours=$(((uptime % 86400) / 3600))
    local minutes=$(((uptime % 3600) / 60))
    
    echo "${days}d ${hours}h ${minutes}m"
}

# Function to check disk space
check_disk_space() {
    local available_mb=$(df / | awk 'NR==2 {print int($4/1024)}')
    local used_percent=$(df / | awk 'NR==2 {print int($5)}' | sed 's/%//')
    
    if [[ $available_mb -lt 100 ]]; then
        set_health_status "disk_space" "unhealthy"
        log_warn "Low disk space: ${available_mb}MB available"
        return 1
    elif [[ $used_percent -gt 90 ]]; then
        set_health_status "disk_space" "degraded"
        log_warn "High disk usage: ${used_percent}%"
        return 2
    else
        set_health_status "disk_space" "healthy"
        return 0
    fi
}

# Function to check admin tools
check_admin_tools() {
    local admin_tools_dir=$(get_config "ADMIN_TOOLS_DIR")
    local tools_working=0
    local tools_total=0
    
    if [[ ! -d "$admin_tools_dir/bin" ]]; then
        set_health_status "admin_tools" "unhealthy"
        log_error "Admin tools directory missing: $admin_tools_dir/bin"
        return 1
    fi
    
    # Check each configured tool
    local tools_array=($(get_tools_array))
    for tool in "${tools_array[@]}"; do
        ((tools_total++))
        
        local tool_path="$admin_tools_dir/bin/$tool"
        if [[ -x "$tool_path" ]]; then
            # Test if tool actually works
            local test_cmd=$(get_tool_info "$tool" "test_cmd")
            if [[ -n "$test_cmd" ]]; then
                if eval "$tool_path $test_cmd" &>/dev/null; then
                    ((tools_working++))
                    log_debug "Tool working: $tool"
                else
                    log_warn "Tool not functioning: $tool"
                fi
            else
                ((tools_working++))
                log_debug "Tool present: $tool"
            fi
        else
            log_warn "Tool missing or not executable: $tool"
        fi
    done
    
    METRICS_TOOL_COUNT="$tools_working/$tools_total"
    
    if [[ $tools_working -eq $tools_total ]]; then
        set_health_status "admin_tools" "healthy"
        return 0
    elif [[ $tools_working -gt 0 ]]; then
        set_health_status "admin_tools" "degraded"
        return 2
    else
        set_health_status "admin_tools" "unhealthy"
        return 1
    fi
}

# Function to check LaunchAgent
check_launchagent() {
    local plist_file="/Library/LaunchAgents/com.adminhub.guestsetup.plist"
    
    if [[ ! -f "$plist_file" ]]; then
        set_health_status "launchagent" "unhealthy"
        log_error "LaunchAgent plist missing: $plist_file"
        return 1
    fi
    
    # Check if LaunchAgent is loaded
    if launchctl list 2>/dev/null | grep -q "com.adminhub.guestsetup"; then
        set_health_status "launchagent" "healthy"
        log_debug "LaunchAgent is loaded and running"
        return 0
    else
        set_health_status "launchagent" "degraded"
        log_warn "LaunchAgent plist exists but not loaded"
        return 2
    fi
}

# Function to check Homebrew
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        set_health_status "homebrew" "unhealthy"
        log_error "Homebrew not installed"
        return 1
    fi
    
    # Run brew doctor to check for issues (it returns 1 even for warnings)
    # If running as root, switch to the regular user to avoid Homebrew warnings
    local doctor_output
    local doctor_exit_code
    
    if [[ $EUID -eq 0 ]]; then
        # Running as root, determine the actual user
        local actual_user
        if [[ -n "$SUDO_USER" ]]; then
            actual_user="$SUDO_USER"
        else
            actual_user=$(stat -f "%Su" /dev/console 2>/dev/null || echo "")
        fi
        
        if [[ -n "$actual_user" && "$actual_user" != "root" ]]; then
            # Run brew doctor as the actual user
            doctor_output=$(su - "$actual_user" -c "brew doctor 2>&1")
            doctor_exit_code=$?
        else
            # Fallback to running directly (will show warning)
            doctor_output=$(brew doctor 2>&1)
            doctor_exit_code=$?
        fi
    else
        # Not root, run normally
        doctor_output=$(brew doctor 2>&1)
        doctor_exit_code=$?
    fi
    
    # Check for "ready to brew" (perfect health)
    if echo "$doctor_output" | grep -q "ready to brew"; then
        set_health_status "homebrew" "healthy"
        return 0
    fi
    
    # Define error keywords that indicate actual problems
    local error_keywords="Error:|Failed|broken|corrupted|permission denied|cannot be found|missing|fatal|critical"
    
    # Check if output contains actual errors
    if echo "$doctor_output" | grep -qE "$error_keywords"; then
        set_health_status "homebrew" "unhealthy"
        log_error "Homebrew has critical errors"
        log_debug "Brew doctor output: $doctor_output"
        return 1
    fi
    
    # If brew doctor returned non-zero but no critical errors found
    if [[ $doctor_exit_code -ne 0 ]]; then
        # Common benign warnings to ignore
        local benign_warnings="Unbrewed header files|Unbrewed .pc files|Unbrewed static libraries|Warning: Some installed formulae|Warning: You have unlinked kegs|Warning: Homebrew's \"sbin\" was not found"
        
        # Count warnings vs errors
        local warning_count=$(echo "$doctor_output" | grep -c "Warning:" || true)
        local error_count=$(echo "$doctor_output" | grep -cE "$error_keywords" || true)
        
        # If only warnings and they're known benign ones
        if [[ $error_count -eq 0 ]] && echo "$doctor_output" | grep -qE "$benign_warnings"; then
            set_health_status "homebrew" "healthy"
            log_debug "Homebrew has only benign warnings"
            return 0
        fi
        
        # Otherwise treat as degraded
        set_health_status "homebrew" "degraded"
        log_warn "Homebrew has warnings (exit code: $doctor_exit_code)"
        log_debug "Warning count: $warning_count, Error count: $error_count"
        return 2
    fi
    
    # If we get here, brew doctor succeeded with no output
    set_health_status "homebrew" "healthy"
    return 0
}

# Function to check permissions
check_permissions() {
    local admin_tools_dir=$(get_config "ADMIN_TOOLS_DIR")
    local permission_issues=0
    
    # Check admin tools directory permissions
    if [[ -d "$admin_tools_dir" ]]; then
        local perms=$(stat -f "%p" "$admin_tools_dir" 2>/dev/null | tail -c 4)
        if [[ "$perms" != "755" ]]; then
            log_warn "Incorrect permissions on admin tools directory: $perms"
            ((permission_issues++))
        fi
        
        # Check individual tool permissions
        if [[ -d "$admin_tools_dir/bin" ]]; then
            while IFS= read -r -d '' tool_file; do
                local tool_perms=$(stat -f "%p" "$tool_file" 2>/dev/null | tail -c 4)
                if [[ "$tool_perms" != "755" ]]; then
                    log_warn "Incorrect permissions on tool: $(basename "$tool_file") ($tool_perms)"
                    ((permission_issues++))
                fi
            done < <(find "$admin_tools_dir/bin" -type f -print0 2>/dev/null)
        fi
    fi
    
    # Check Homebrew permissions
    if [[ -d "/opt/homebrew" ]]; then
        local homebrew_readable=true
        find /opt/homebrew/bin -type f -executable 2>/dev/null | head -5 | while read -r file; do
            if [[ ! -r "$file" ]]; then
                homebrew_readable=false
                break
            fi
        done
        
        if [[ "$homebrew_readable" == "false" ]]; then
            log_warn "Homebrew files not readable by all users"
            ((permission_issues++))
        fi
    fi
    
    if [[ $permission_issues -eq 0 ]]; then
        set_health_status "permissions" "healthy"
        return 0
    elif [[ $permission_issues -lt 3 ]]; then
        set_health_status "permissions" "degraded"
        return 2
    else
        set_health_status "permissions" "unhealthy"
        return 1
    fi
}

# Function to check guest setup
check_guest_setup() {
    local setup_script="/usr/local/bin/guest_setup_auto.sh"
    local login_script="/usr/local/bin/guest_login_setup"
    
    if [[ ! -f "$setup_script" ]]; then
        set_health_status "guest_setup" "unhealthy"
        log_error "Guest setup script missing: $setup_script"
        return 1
    fi
    
    if [[ ! -f "$login_script" ]]; then
        set_health_status "guest_setup" "degraded"
        log_warn "Guest login script missing: $login_script"
        return 2
    fi
    
    # Check if scripts are executable
    if [[ -x "$setup_script" && -x "$login_script" ]]; then
        set_health_status "guest_setup" "healthy"
        return 0
    else
        set_health_status "guest_setup" "degraded"
        log_warn "Guest setup scripts not executable"
        return 2
    fi
}

# Function to run all health checks
run_health_checks() {
    log_info "Running AdminHub health checks..."
    
    local overall_score=0
    local check_count=0
    
    # Run individual checks
    check_disk_space; local disk_result=$?
    check_admin_tools; local tools_result=$?
    check_launchagent; local agent_result=$?
    check_homebrew; local brew_result=$?
    check_permissions; local perms_result=$?
    check_guest_setup; local guest_result=$?
    
    # Calculate overall health score
    for result in $disk_result $tools_result $agent_result $brew_result $perms_result $guest_result; do
        case $result in
            0) overall_score=$((overall_score + 100)) ;;  # healthy
            2) overall_score=$((overall_score + 50)) ;;   # degraded
            *) overall_score=$((overall_score + 0)) ;;    # unhealthy
        esac
        ((check_count++))
    done
    
    local avg_score=$((overall_score / check_count))
    
    if [[ $avg_score -ge 90 ]]; then
        set_health_status "overall" "healthy"
    elif [[ $avg_score -ge 50 ]]; then
        set_health_status "overall" "degraded"
    else
        set_health_status "overall" "unhealthy"
    fi
    
    METRICS_LAST_CHECK=$(date '+%Y-%m-%d %H:%M:%S')
}

# Function to save health status to file
save_health_status() {
    local status_file="$1"
    
    mkdir -p "$(dirname "$status_file")" 2>/dev/null
    
    cat > "$status_file" << EOF
{
  "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "overall_status": "$(get_health_status overall)",
  "components": {
    "admin_tools": "$(get_health_status admin_tools)",
    "guest_setup": "$(get_health_status guest_setup)",
    "launchagent": "$(get_health_status launchagent)",
    "homebrew": "$(get_health_status homebrew)",
    "permissions": "$(get_health_status permissions)",
    "disk_space": "$(get_health_status disk_space)"
  },
  "metrics": {
    "setup_time": "$METRICS_SETUP_TIME",
    "tool_count": "$METRICS_TOOL_COUNT",
    "error_count": "$METRICS_ERROR_COUNT",
    "guest_logins": "$METRICS_GUEST_LOGINS",
    "last_check": "$METRICS_LAST_CHECK"
  },
  "system_info": {
    "hostname": "$(hostname)",
    "macos_version": "$(sw_vers -productVersion 2>/dev/null || echo "unknown")",
    "uptime": "$(get_uptime)",
    "current_user": "$(whoami)"
  }
}
EOF
    
    chmod 644 "$status_file" 2>/dev/null
}

# Function to display health status
show_health_status() {
    local show_details="${1:-false}"
    
    echo "╔═══════════════════════════════════════╗"
    echo "║         AdminHub Health Status        ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    # Overall status
    local overall_status=$(get_health_status "overall")
    local overall_color=$(get_status_color "$overall_status")
    local overall_upper=$(to_upper "$overall_status")
    echo -e "🏥 Overall Status: ${overall_color}${overall_upper}\033[0m"
    echo ""
    
    # Component status
    echo "📊 Component Status:"
    local components="admin_tools guest_setup launchagent homebrew permissions disk_space"
    for component in $components; do
        local status=$(get_health_status "$component")
        local icon="❓"
        
        case "$status" in
            "healthy") icon="✅" ;;
            "degraded") icon="⚠️ " ;;
            "unhealthy") icon="❌" ;;
        esac
        
        local status_upper=$(to_upper "$status")
        printf "  %-15s %s %s\n" "$component:" "$icon" "$status_upper"
    done
    
    echo ""
    echo "📈 Metrics:"
    echo "  Tools Available: $METRICS_TOOL_COUNT"
    echo "  Last Check:      $METRICS_LAST_CHECK"
    echo "  System Uptime:   $(get_uptime)"
    
    if [[ "$show_details" == "true" ]]; then
        echo ""
        echo "🔍 Detailed Information:"
        echo "  Admin Tools Dir: $(get_config 'ADMIN_TOOLS_DIR')"
        echo "  Guest Tools Dir: $(get_config 'GUEST_TOOLS_DIR')"
        echo "  Hostname:        $(hostname)"
        echo "  macOS Version:   $(sw_vers -productVersion 2>/dev/null || echo "unknown")"
        echo "  Current User:    $(whoami)"
    fi
    
    echo ""
}

# Function to monitor guest setup performance
monitor_guest_setup() {
    local start_time=$(date +%s)
    
    log_info "Monitoring guest setup performance..."
    
    # Simulate or monitor actual guest setup
    if [[ "$USER" == "Guest" ]]; then
        local setup_script="/usr/local/bin/guest_setup_auto.sh"
        if [[ -f "$setup_script" ]]; then
            bash "$setup_script"
        fi
    fi
    
    local end_time=$(date +%s)
    local setup_duration=$((end_time - start_time))
    
    METRICS_SETUP_TIME="${setup_duration}s"
    log_info "Guest setup completed in ${setup_duration}s"
    
    return 0
}

# Function to generate alerts
generate_alerts() {
    local alert_level="$1"  # info, warn, error
    local message="$2"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$alert_level] $message" >> "$ALERTS_FILE"
    
    case "$alert_level" in
        "error")
            log_error "ALERT: $message"
            ;;
        "warn")
            log_warn "ALERT: $message"
            ;;
        *)
            log_info "ALERT: $message"
            ;;
    esac
}

# Function to check for issues and generate alerts
check_and_alert() {
    run_health_checks
    
    # Generate alerts based on health status
    local overall_status=$(get_health_status "overall")
    case "$overall_status" in
        "unhealthy")
            generate_alerts "error" "AdminHub system is unhealthy - immediate attention required"
            ;;
        "degraded")
            generate_alerts "warn" "AdminHub system is degraded - some components need attention"
            ;;
        "healthy")
            generate_alerts "info" "AdminHub system is healthy"
            ;;
    esac
    
    # Specific component alerts
    local components="admin_tools guest_setup launchagent homebrew permissions disk_space"
    for component in $components; do
        local status=$(get_health_status "$component")
        case "$status" in
            "unhealthy")
                generate_alerts "error" "Component '$component' is unhealthy"
                ;;
            "degraded")
                generate_alerts "warn" "Component '$component' is degraded"
                ;;
        esac
    done
}

# Function to run continuous monitoring
continuous_monitoring() {
    local interval="${1:-300}"  # 5 minutes default
    
    log_info "Starting continuous monitoring (interval: ${interval}s)"
    
    while true; do
        check_and_alert
        save_health_status "$HEALTH_CHECK_FILE"
        
        log_debug "Health check completed, sleeping for ${interval}s"
        sleep "$interval"
    done
}

# Main monitoring command
case "${1:-status}" in
    "status")
        run_health_checks
        show_health_status "${2:-false}"
        ;;
    "detailed")
        run_health_checks
        show_health_status "true"
        ;;
    "json")
        run_health_checks
        save_health_status "$HEALTH_CHECK_FILE"
        cat "$HEALTH_CHECK_FILE"
        ;;
    "monitor")
        continuous_monitoring "${2:-300}"
        ;;
    "alerts")
        [[ -f "$ALERTS_FILE" ]] && tail -n "${2:-20}" "$ALERTS_FILE" || echo "No alerts found"
        ;;
    "guest")
        monitor_guest_setup
        ;;
    *)
        echo "Usage: $0 {status|detailed|json|monitor [interval]|alerts [lines]|guest}"
        echo ""
        echo "Commands:"
        echo "  status    - Show basic health status"
        echo "  detailed  - Show detailed health status"
        echo "  json      - Output status as JSON"
        echo "  monitor   - Run continuous monitoring"
        echo "  alerts    - Show recent alerts"
        echo "  guest     - Monitor guest setup performance"
        exit 1
        ;;
esac 
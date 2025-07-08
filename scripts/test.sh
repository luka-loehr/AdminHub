#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Test Script
# Checks if everything is correctly installed

echo "╔═══════════════════════════════════════╗"
echo "║        🧪 AdminHub Test 🧪            ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test function
check() {
    if [ $1 -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "  ${RED}✗${NC} $2"
        return 1
    fi
}

# Counters
total=0
passed=0

echo "📋 Testing installation..."
echo ""

# 1. Admin tools directory
echo "🔍 Checking directories:"
test -d "/opt/admin-tools/bin"
result=$?
((total++))
check $result "/opt/admin-tools/bin exists" && ((passed++))

# 2. LaunchAgent
echo ""
echo "🤖 Checking LaunchAgent:"
test -f "/Library/LaunchAgents/com.adminhub.guestsetup.plist"
result=$?
((total++))
check $result "LaunchAgent installed" && ((passed++))

launchctl list 2>/dev/null | grep -q "com.adminhub.guestsetup"
result=$?
((total++))
check $result "LaunchAgent loaded" && ((passed++))

# 3. Scripts
echo ""
echo "📜 Checking scripts:"
test -x "/usr/local/bin/guest_login_setup"
result=$?
((total++))
check $result "guest_login_setup installed" && ((passed++))

test -x "/usr/local/bin/guest_setup_auto.sh"
result=$?
((total++))
check $result "guest_setup_auto.sh installed" && ((passed++))

# 4. Tools
echo ""
echo "🔧 Checking tools in /opt/admin-tools/bin:"
tools=("brew" "python3" "python" "git" "pip3" "pip")
for tool in "${tools[@]}"; do
    test -L "/opt/admin-tools/bin/$tool" -o -f "/opt/admin-tools/bin/$tool"
    result=$?
    ((total++))
    check $result "$tool" && ((passed++))
done

# 5. Permissions
echo ""
echo "🔐 Checking permissions:"
stat -f "%p" /opt/admin-tools 2>/dev/null | grep -q "755$"
result=$?
((total++))
check $result "/opt/admin-tools has correct permissions" && ((passed++))

# Summary
echo ""
echo "═══════════════════════════════════════════"
if [ $passed -eq $total ]; then
    echo -e "${GREEN}✅ All tests passed! ($passed/$total)${NC}"
    echo ""
    echo "🎉 AdminHub is ready!"
    echo "   Next: Log in as Guest user"
else
    echo -e "${YELLOW}⚠️  Some tests failed! ($passed/$total)${NC}"
    echo ""
    echo "🔧 Run './setup.sh' again"
fi
echo "═══════════════════════════════════════════" 
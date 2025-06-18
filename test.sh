#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Test-Script
# Überprüft ob alles korrekt installiert ist

echo "╔═══════════════════════════════════════╗"
echo "║        🧪 AdminHub Test 🧪            ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Farben für Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test-Funktion
check() {
    if [ $1 -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "  ${RED}✗${NC} $2"
        return 1
    fi
}

# Zähler
total=0
passed=0

echo "📋 Teste Installation..."
echo ""

# 1. Admin-Tools Verzeichnis
echo "🔍 Prüfe Verzeichnisse:"
test -d "/opt/admin-tools/bin"
result=$?
((total++))
check $result "/opt/admin-tools/bin existiert" && ((passed++))

# 2. LaunchAgent
echo ""
echo "🤖 Prüfe LaunchAgent:"
test -f "/Library/LaunchAgents/com.adminhub.guestsetup.plist"
result=$?
((total++))
check $result "LaunchAgent installiert" && ((passed++))

sudo launchctl list 2>/dev/null | grep -q "com.adminhub.guestsetup"
result=$?
((total++))
check $result "LaunchAgent geladen" && ((passed++))

# 3. Scripts
echo ""
echo "📜 Prüfe Scripts:"
test -x "/usr/local/bin/guest_login_setup"
result=$?
((total++))
check $result "guest_login_setup installiert" && ((passed++))

test -x "/usr/local/bin/guest_setup_auto.sh"
result=$?
((total++))
check $result "guest_setup_auto.sh installiert" && ((passed++))

# 4. Tools
echo ""
echo "🔧 Prüfe Tools in /opt/admin-tools/bin:"
tools=("python3" "git" "node" "npm" "jq" "wget")
for tool in "${tools[@]}"; do
    test -L "/opt/admin-tools/bin/$tool" -o -f "/opt/admin-tools/bin/$tool"
    result=$?
    ((total++))
    check $result "$tool" && ((passed++))
done

# 5. Berechtigungen
echo ""
echo "🔐 Prüfe Berechtigungen:"
stat -f "%p" /opt/admin-tools 2>/dev/null | grep -q "755$"
result=$?
((total++))
check $result "/opt/admin-tools hat korrekte Berechtigungen" && ((passed++))

# Zusammenfassung
echo ""
echo "═══════════════════════════════════════════"
if [ $passed -eq $total ]; then
    echo -e "${GREEN}✅ Alle Tests bestanden! ($passed/$total)${NC}"
    echo ""
    echo "🎉 AdminHub ist bereit!"
    echo "   Als nächstes: Als Guest-User einloggen"
else
    echo -e "${YELLOW}⚠️  Einige Tests fehlgeschlagen! ($passed/$total)${NC}"
    echo ""
    echo "🔧 Führe './setup.sh' erneut aus"
fi
echo "═══════════════════════════════════════════" 
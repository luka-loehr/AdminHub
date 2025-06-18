#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Deinstallation
# Entfernt alle installierten Komponenten

set -e

echo "╔═══════════════════════════════════════╗"
echo "║      🗑️  AdminHub Deinstallation      ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Prüfe ob als sudo ausgeführt
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Bitte mit sudo ausführen: sudo ./uninstall.sh"
    exit 1
fi

echo "⚠️  WARNUNG: Dies entfernt alle AdminHub-Komponenten!"
echo -n "Fortfahren? (j/N): "
read -r response
if [[ ! "$response" =~ ^[jJ]$ ]]; then
    echo "Abgebrochen."
    exit 0
fi

echo ""
echo "🧹 Entferne Komponenten..."

# LaunchAgents entfernen
echo "  • Entferne LaunchAgents..."
launchctl unload /Library/LaunchAgents/com.adminhub.guestsetup.plist 2>/dev/null || true
rm -f /Library/LaunchAgents/com.adminhub.guestsetup.plist
rm -f /Library/LaunchAgents/com.adminhub.guestterminal.plist

# Scripts entfernen
echo "  • Entferne Scripts..."
rm -f /usr/local/bin/guest_login_setup
rm -f /usr/local/bin/guest_setup_auto.sh
rm -f /usr/local/bin/guest_setup_final.sh
rm -f /usr/local/bin/simple_guest_setup.sh
rm -f /usr/local/bin/open_guest_terminal

# Admin-Tools entfernen (optional)
echo ""
echo -n "Admin-Tools in /opt/admin-tools/ auch entfernen? (j/N): "
read -r response
if [[ "$response" =~ ^[jJ]$ ]]; then
    echo "  • Entferne Admin-Tools..."
    rm -rf /opt/admin-tools
fi

# Logs aufräumen
echo "  • Räume Logs auf..."
rm -f /tmp/adminhub-*.log
rm -f /tmp/adminhub-*.err

echo ""
echo "✅ Deinstallation abgeschlossen!"
echo ""
echo "Hinweis: Homebrew und die installierten Pakete wurden NICHT entfernt." 
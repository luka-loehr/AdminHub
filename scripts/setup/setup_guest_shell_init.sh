#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Setup Guest Shell Initialisierung
# Konfiguriert einen LaunchAgent der die Guest-Shell bei jedem Login einrichtet

set -e

echo "🔧 Richte Guest Shell Initialisierung ein..."

# Prüfe ob als root ausgeführt
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Bitte mit sudo ausführen"
    exit 1
fi

# Das Auto-Setup Script kopieren
echo "📋 Installiere Auto-Setup Script..."
cp scripts/runtime/guest_setup_auto.sh /usr/local/bin/
chmod 755 /usr/local/bin/guest_setup_auto.sh

# Das Login-Setup Script kopieren
echo "📋 Installiere Login-Setup Script..."
cp scripts/setup/guest_login_setup.sh /usr/local/bin/guest_login_setup
chmod 755 /usr/local/bin/guest_login_setup

# Den LaunchAgent installieren
echo "🤖 Installiere LaunchAgent..."
cp launchagents/com.adminhub.guestsetup.plist /Library/LaunchAgents/
chmod 644 /Library/LaunchAgents/com.adminhub.guestsetup.plist

# Den LaunchAgent laden
launchctl load /Library/LaunchAgents/com.adminhub.guestsetup.plist 2>/dev/null || true

# Hinweis: Der alte com.adminhub.guestterminal.plist wird nicht mehr benötigt
# Terminal wird jetzt vom guest_login_setup Script geöffnet

echo ""
echo "✅ Guest Shell Initialisierung konfiguriert!"
echo ""
echo "Das Setup läuft automatisch wenn der Guest-Benutzer das Terminal öffnet."
echo "Keine Berechtigungsdialoge erforderlich! 🎉" 
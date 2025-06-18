#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Haupt-Installationsskript
# Dieses Script installiert das komplette AdminHub System

set -e  # Bei Fehler beenden

echo "🚀 AdminHub Installationsskript"
echo "==============================="
echo "© 2025 Luka Löhr"
echo ""

# Prüfe ob als sudo ausgeführt
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Bitte mit sudo ausführen: sudo ./install_adminhub.sh"
    exit 1
fi

# Prüfe ob Homebrew installiert ist
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew ist nicht installiert. Bitte zuerst installieren:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Voraussetzungen geprüft"
echo ""

# Alle Scripts ausführbar machen
echo "📝 Mache Scripts ausführbar..."
find scripts -name "*.sh" -type f -exec chmod +x {} \;

# Haupt-Setup ausführen
echo "🔧 Führe Haupt-Setup aus..."
./scripts/setup/guest_tools_setup.sh

# Berechtigungen korrigieren
echo "🔐 Korrigiere Homebrew-Berechtigungen..."
./scripts/utils/fix_homebrew_permissions.sh

# Hinweis: LaunchAgent-Installation wird jetzt von setup_guest_shell_init.sh übernommen
# Führe dieses Script für das berechtigungsfreie Guest-Setup aus

echo ""
echo "✅ Installation abgeschlossen!"
echo ""

# PATH für aktuellen Benutzer einrichten (nicht Guest)
echo "🔄 Richte PATH für sofortige Nutzung ein..."

# Original-Benutzer ermitteln der sudo ausgeführt hat
ORIGINAL_USER=$(who am i | awk '{print $1}')
USER_HOME=$(eval echo ~$ORIGINAL_USER)

# PATH für aktuelle Sitzung hinzufügen
export PATH="/opt/admin-tools/bin:$PATH"

# Shell-Konfigurationsdateien aktualisieren
if [ -f "$USER_HOME/.zshrc" ]; then
    # Prüfe ob bereits hinzugefügt
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.zshrc"; then
        echo "" >> "$USER_HOME/.zshrc"
        echo "# AdminHub Tools" >> "$USER_HOME/.zshrc"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.zshrc"
        echo "✅ Zu .zshrc hinzugefügt"
    fi
fi

if [ -f "$USER_HOME/.bash_profile" ]; then
    # Prüfe ob bereits hinzugefügt
    if ! grep -q "/opt/admin-tools/bin" "$USER_HOME/.bash_profile"; then
        echo "" >> "$USER_HOME/.bash_profile"
        echo "# AdminHub Tools" >> "$USER_HOME/.bash_profile"
        echo "export PATH=\"/opt/admin-tools/bin:\$PATH\"" >> "$USER_HOME/.bash_profile"
        echo "✅ Zu .bash_profile hinzugefügt"
    fi
fi

echo ""
echo "🎉 Tools sind jetzt verfügbar!"
echo ""
echo "Verfügbare Befehle:"
echo "  • python3 - Python 3 mit pip3"
echo "  • git - Versionskontrolle"
echo "  • node - Node.js Runtime"
echo "  • npm - Node Package Manager"
echo "  • jq - JSON Prozessor"
echo "  • wget - Datei-Downloader"
echo ""

# Script für Installationstest erstellen
cat > /tmp/test_adminhub.sh << 'EOF'
#!/bin/bash
clear
echo "🚀 AdminHub Tools bereit!"
echo "========================"
echo "© 2025 Luka Löhr"
echo ""
export PATH="/opt/admin-tools/bin:$PATH"

echo "📋 Installierte Tools:"
echo ""

if command -v python3 &> /dev/null; then
    echo "  ✅ Python $(python3 --version 2>&1 | cut -d' ' -f2)"
else
    echo "  ❌ Python3 nicht gefunden"
fi

if command -v git &> /dev/null; then
    echo "  ✅ Git $(git --version | cut -d' ' -f3)"
else
    echo "  ❌ Git nicht gefunden"
fi

if command -v node &> /dev/null; then
    echo "  ✅ Node.js $(node --version 2>/dev/null || echo 'installiert')"
else
    echo "  ❌ Node nicht gefunden"
fi

if command -v npm &> /dev/null; then
    echo "  ✅ npm $(npm --version 2>/dev/null || echo 'installiert')"
else
    echo "  ❌ npm nicht gefunden"
fi

echo ""
echo "🎉 Alle Tools sind bereit!"
echo ""
echo "Probiere diese Befehle:"
echo "  • python3 --version"
echo "  • git status"
echo "  • node --version"
echo ""

# Aufräumen
rm /tmp/test_adminhub.sh

# Hinweis: Wir verwenden kein AppleScript mehr für Terminal-Verwaltung
EOF

chmod +x /tmp/test_adminhub.sh

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Öffne neues Terminal mit bereiten Tools..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "➡️  Neues Terminal öffnet sich in 2 Sekunden"
echo ""
sleep 2

# Neues Terminal öffnen und Test-Script ausführen (ohne AppleScript)
/usr/bin/open -a Terminal /tmp/test_adminhub.sh

echo "✅ Neues Terminal geöffnet!"
echo ""
echo "Dieses Fenster schließt sich in 5 Sekunden..."
echo ""
echo "Für Guest-Benutzer:"
echo "1. Abmelden und als Guest einloggen"
echo "2. Terminal öffnet sich automatisch mit allen Tools"
echo ""
echo "Bei Problemen siehe docs/SETUP_README.md" 
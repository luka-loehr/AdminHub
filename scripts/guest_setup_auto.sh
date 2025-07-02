#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Guest Auto Setup
# Läuft automatisch wenn der Guest-Benutzer das Terminal öffnet

# Nur für Guest-Benutzer ausführen
if [[ "$(whoami)" != "Guest" ]]; then
    return 0 2>/dev/null || exit 0
fi

# Prüfe ob bereits in dieser Sitzung initialisiert
if [[ "$ADMINHUB_INITIALIZED" == "true" ]]; then
    return 0 2>/dev/null || exit 0
fi

# Als initialisiert markieren
export ADMINHUB_INITIALIZED="true"

# Prüfe ob dies ein interaktives Terminal ist
if [[ ! -t 0 ]]; then
    return 0 2>/dev/null || exit 0
fi

# Admin-Tools Verzeichnis
ADMIN_TOOLS_DIR="/opt/admin-tools"
GUEST_TOOLS_DIR="/Users/Guest/tools"

# Prüfe ob Setup benötigt wird (Tools-Verzeichnis existiert nicht)
if [[ ! -d "$GUEST_TOOLS_DIR/bin" ]]; then
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║     🚀 AdminHub Guest Setup 🚀         ║"
    echo "║        © 2025 Luka Löhr                ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Entwicklertools werden eingerichtet..."
    echo ""
    
    # Prüfe ob Admin-Tools existieren
    if [[ ! -d "$ADMIN_TOOLS_DIR/bin" ]]; then
        echo "⚠️  Admin-Tools nicht gefunden!"
        echo "Bitte Administrator kontaktieren."
        echo ""
        echo "Der Administrator muss folgendes ausführen:"
        echo "  cd /pfad/zum/AdminHub && sudo ./setup.sh"
        exit 1
    fi
    
    # Erstelle Guest Tools Verzeichnis
    echo "📁 Erstelle Tools-Verzeichnis..."
    mkdir -p "$GUEST_TOOLS_DIR/bin"
    
    # Kopiere Tools
    echo "📋 Kopiere Entwicklertools..."
    cp -R "$ADMIN_TOOLS_DIR/bin/"* "$GUEST_TOOLS_DIR/bin/" 2>/dev/null || {
        echo "❌ Fehler beim Kopieren der Tools!"
        echo "Bitte Administrator kontaktieren."
        exit 1
    }
    
    # Setze PATH
    export PATH="$GUEST_TOOLS_DIR/bin:$PATH"
    
    echo ""
    echo "✅ Setup abgeschlossen!"
    echo ""
    echo "Verfügbare Tools:"
    echo "  • python3 - Python Programmierung"
    echo "  • git     - Versionskontrolle"
    echo "  • node    - JavaScript Runtime"
    echo "  • npm     - Node Package Manager"
    echo "  • jq      - JSON Prozessor"
    echo "  • wget    - Datei-Download"
    echo ""
    echo "Viel Spaß beim Programmieren! 🎉"
    echo ""
else
    # Tools bereits eingerichtet, nur PATH setzen
    export PATH="$GUEST_TOOLS_DIR/bin:$PATH"
    
    # Willkommensnachricht nur einmal pro Sitzung zeigen
    if [[ "$ADMINHUB_WELCOME_SHOWN" != "true" ]]; then
        export ADMINHUB_WELCOME_SHOWN="true"
        echo ""
        echo "✨ AdminHub Tools sind bereit!"
        echo "Verfügbar: python3, git, node, npm, jq, wget"
        echo "© 2025 Luka Löhr"
        echo ""
    fi
fi 
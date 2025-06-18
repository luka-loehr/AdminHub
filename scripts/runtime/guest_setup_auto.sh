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

# Prüfe ob Setup benötigt wird (Tools-Verzeichnis existiert nicht)
if [[ ! -d "/Users/Guest/tools/bin" ]]; then
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║     🚀 AdminHub Guest Setup 🚀         ║"
    echo "║        © 2025 Luka Löhr                ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Entwicklertools werden eingerichtet..."
    echo ""
    
    # Das eigentliche Setup ausführen
    if [[ -f /usr/local/bin/guest_setup_final.sh ]]; then
        /usr/local/bin/guest_setup_final.sh
    elif [[ -f /usr/local/bin/simple_guest_setup.sh ]]; then
        /usr/local/bin/simple_guest_setup.sh
    else
        echo "⚠️  Setup-Script nicht gefunden!"
        echo "Bitte Administrator kontaktieren."
    fi
else
    # Tools bereits eingerichtet, nur PATH setzen
    export PATH="/Users/Guest/tools/bin:$PATH"
    
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
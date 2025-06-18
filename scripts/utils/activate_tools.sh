#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Tools Aktivator
# Dieses Script aktiviert die Tools sofort in der aktuellen Shell

# Prüfe ob Script per source aufgerufen wird
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ Dieses Script muss mit source aufgerufen werden!"
    echo ""
    echo "Bitte ausführen:"
    echo "  source activate_tools.sh"
    echo ""
    echo "oder:"
    echo "  . activate_tools.sh"
    exit 1
fi

echo "🔄 Aktiviere AdminHub Tools..."
echo "© 2025 Luka Löhr"

# Zum PATH hinzufügen
export PATH="/opt/admin-tools/bin:$PATH"

# Prüfe ob Tools verfügbar sind
if command -v python3 &> /dev/null && [ -L "/opt/admin-tools/bin/python3" ]; then
    echo "✅ Tools aktiviert!"
    echo ""
    echo "Verfügbare Befehle:"
    echo "  • python3 ($(python3 --version 2>&1))"
    echo "  • git ($(git --version))"
    
    if [ -L "/opt/admin-tools/bin/node" ]; then
        echo "  • node ($(node --version 2>/dev/null || echo 'Berechtigungen prüfen'))"
        echo "  • npm ($(npm --version 2>/dev/null || echo 'Berechtigungen prüfen'))"
    fi
    
    if [ -L "/opt/admin-tools/bin/jq" ]; then
        echo "  • jq ($(jq --version 2>/dev/null || echo 'Berechtigungen prüfen'))"
    fi
    
    if [ -L "/opt/admin-tools/bin/wget" ]; then
        echo "  • wget (installiert)"
    fi
    
    echo ""
    echo "🎉 Du kannst jetzt alle Tools in DIESEM Terminal nutzen!"
    echo ""
    echo "Hinweis: Diese Aktivierung gilt nur für die aktuelle Terminal-Sitzung."
    echo "Neue Terminals haben die Tools automatisch wenn install_adminhub.sh ausgeführt wurde"
else
    echo "❌ Tools nicht gefunden. Bitte ausführen: sudo ./install_adminhub.sh"
fi 
#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Schnell-Installation
# Installiert alles was nötig ist in einem Schritt

set -e

echo "╔═══════════════════════════════════════╗"
echo "║        🚀 AdminHub Setup 🚀           ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Prüfe ob als sudo ausgeführt
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Bitte mit sudo ausführen: sudo ./setup.sh"
    exit 1
fi

# Schritt 1: Hauptinstallation
echo "📦 Schritt 1/2: Installiere Entwicklertools..."
./scripts/install_adminhub.sh

# Schritt 2: Guest-Setup aktivieren
echo ""
echo "🔧 Schritt 2/2: Aktiviere Guest-Account Setup..."
./scripts/setup/setup_guest_shell_init.sh

echo ""
echo "═══════════════════════════════════════════"
echo "✅ Installation abgeschlossen!"
echo "═══════════════════════════════════════════"
echo ""
echo "🎯 Nächste Schritte:"
echo "   1. Als Guest-User einloggen"
echo "   2. Terminal öffnet sich automatisch"
echo "   3. Alle Tools sind sofort verfügbar!"
echo ""
echo "📝 Bei Problemen: siehe README.md" 
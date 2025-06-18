#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Guest Setup - Alles in einem Terminal
echo "🚀 Richte AdminHub Tools ein..."
echo "© 2025 Luka Löhr"
echo ""

# Umgebung in .zprofile einrichten falls noch nicht geschehen
if ! grep -q "AdminHub Tools Path" ~/.zprofile 2>/dev/null; then
    echo "📝 Konfiguriere Umgebung..."
    cat >> ~/.zprofile << 'EOF'

# AdminHub Tools Path
export PATH="/opt/admin-tools/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
EOF
    echo "✅ Umgebung konfiguriert"
fi

# Bash Update-Meldungen unterdrücken
export BASH_SILENCE_DEPRECATION_WARNING=1

echo ""
echo "🔄 Lade Tools..."

# Profil laden um PATH-Updates zu erhalten
source ~/.zprofile

# Kleine Verzögerung für visuellen Effekt
sleep 1

# Bildschirm leeren und Erfolgsbildschirm zeigen
clear
echo "🚀 AdminHub Tools bereit!"
echo "========================"
echo "© 2025 Luka Löhr"
echo ""
echo "📋 Installierte Tools:"
echo ""

# Tools mit schöner Formatierung prüfen
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

if command -v jq &> /dev/null; then
    echo "  ✅ jq $(jq --version 2>/dev/null || echo 'installiert')"
else
    echo "  ❌ jq nicht gefunden"
fi

if command -v wget &> /dev/null; then
    echo "  ✅ wget installiert"
else
    echo "  ❌ wget nicht gefunden"
fi

echo ""
echo "🎉 Alle Tools sind bereit!"
echo ""
echo "Probiere diese Befehle:"
echo "  • python3 --version"
echo "  • git status" 
echo "  • node --version"
echo ""
echo "💡 Zero-Persistence: Alles wird beim Logout gelöscht"
echo ""

# Neue Shell mit aktualisiertem PATH starten
exec bash -l 
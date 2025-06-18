#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# Homebrew-Berechtigungen korrigieren damit Guest die Tools nutzen kann

echo "🔧 Korrigiere Homebrew-Berechtigungen für Guest-Zugriff..."

# Homebrew-Verzeichnisse für alle lesbar machen
sudo chmod -R o+rX /opt/homebrew/bin
sudo chmod -R o+rX /opt/homebrew/Cellar/node
sudo chmod -R o+rX /opt/homebrew/Cellar/wget
sudo chmod -R o+rX /opt/homebrew/Cellar/jq
sudo chmod -R o+rX /opt/homebrew/Cellar/git
sudo chmod -R o+rX /opt/homebrew/lib
sudo chmod -R o+rX /opt/homebrew/share

echo "✅ Berechtigungen korrigiert!"
echo ""
echo "Die folgenden Tools sollten jetzt für Guest zugänglich sein:"
echo "  - node, npm (aus /opt/homebrew/bin/)"
echo "  - wget (aus /opt/homebrew/bin/)"
echo "  - jq (aus /opt/homebrew/bin/)"
echo "  - git (aus /opt/homebrew/bin/)" 
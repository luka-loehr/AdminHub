#!/bin/bash
# Copyright (c) 2025 Luka Löhr

# AdminHub Guest Login Setup
# Läuft automatisch wenn sich der Guest-Benutzer einloggt (via LaunchAgent)

# Nur für Guest-Benutzer ausführen
if [[ "$(whoami)" != "Guest" ]]; then
    exit 0
fi

# Start protokollieren
echo "[$(date)] Guest Login Setup gestartet" >> /tmp/adminhub-setup.log

# Guest Home-Verzeichnis (wird bei jedem Login neu erstellt)
GUEST_HOME="/Users/Guest"

# Kurz warten bis das Home-Verzeichnis vollständig erstellt ist
sleep 1

# .zshrc mit unserem Auto-Setup erstellen
echo "[$(date)] Erstelle .zshrc" >> /tmp/adminhub-setup.log
cat > "$GUEST_HOME/.zshrc" << 'EOF'
# AdminHub Guest Setup
# Automatisch generiert beim Login

# Das Auto-Setup Script laden
if [ -f /usr/local/bin/guest_setup_auto.sh ]; then
    source /usr/local/bin/guest_setup_auto.sh
fi
EOF

# .bash_profile für Bash-Kompatibilität erstellen
echo "[$(date)] Erstelle .bash_profile" >> /tmp/adminhub-setup.log
cat > "$GUEST_HOME/.bash_profile" << 'EOF'
# AdminHub Guest Setup
# Automatisch generiert beim Login

# Das Auto-Setup Script laden
if [ -f /usr/local/bin/guest_setup_auto.sh ]; then
    source /usr/local/bin/guest_setup_auto.sh
fi
EOF

# Berechtigungen setzen
chmod 644 "$GUEST_HOME/.zshrc" "$GUEST_HOME/.bash_profile" 2>/dev/null || true

# Terminal automatisch öffnen
echo "[$(date)] Öffne Terminal" >> /tmp/adminhub-setup.log
/usr/bin/open -a Terminal

echo "[$(date)] Guest Login Setup abgeschlossen" >> /tmp/adminhub-setup.log 
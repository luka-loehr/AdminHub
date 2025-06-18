# AdminHub - Entwicklertools für Guest-Accounts

Ein System, das automatisch Entwicklertools (Python, Git, Node.js, etc.) für Guest-Benutzer auf Schul-MacBooks bereitstellt - ohne nervige Berechtigungsdialoge!

## 🚀 Schnellstart

```bash
# Repository klonen
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub

# Installation ausführen (als Admin)
sudo ./setup.sh
```

Das war's! Beim nächsten Guest-Login:
- Terminal öffnet sich automatisch
- Alle Tools sind sofort verfügbar
- Keine Berechtigungsdialoge!

## 📋 Was wird installiert?

- **Python 3** mit pip
- **Git** für Versionskontrolle  
- **Node.js** & npm
- **jq** für JSON-Verarbeitung
- **wget** für Downloads

## 🎯 Funktionsweise

1. **Admin installiert einmalig die Tools** in `/opt/admin-tools/`
2. **LaunchAgent** läuft bei jedem Guest-Login
3. **Automatisches Setup** ohne Benutzerinteraktion
4. **Tools bleiben erhalten** auch wenn Guest-Account gelöscht wird

## 📁 Projektstruktur

```
AdminHub/
├── setup.sh                    # Haupt-Installationsskript
├── scripts/
│   ├── install/               # Installations-Skripte
│   ├── setup/                 # Setup & Konfiguration
│   ├── runtime/               # Laufzeit-Skripte
│   ├── utils/                 # Hilfsprogramme
│   └── deprecated/            # Alte Skripte (nicht mehr verwenden!)
├── launchagents/              # macOS LaunchAgents
└── docs/                      # Dokumentation
```

## 🔧 Erweiterte Installation

Falls der automatische Setup nicht funktioniert:

```bash
# 1. Tools manuell installieren
sudo ./scripts/setup/guest_tools_setup.sh install-admin

# 2. Guest-Setup aktivieren  
sudo ./scripts/setup/setup_guest_shell_init.sh

# 3. Installation testen
./scripts/setup/guest_tools_setup.sh test
```

## 🐛 Fehlerbehebung

### Terminal öffnet sich nicht automatisch
```bash
# LaunchAgent neu laden
sudo launchctl unload /Library/LaunchAgents/com.adminhub.guestsetup.plist
sudo launchctl load /Library/LaunchAgents/com.adminhub.guestsetup.plist
```

### Tools nicht verfügbar
```bash
# Als Guest-User im Terminal:
source /usr/local/bin/guest_setup_auto.sh
```

### Logs prüfen
```bash
# Setup-Logs
cat /tmp/adminhub-setup.log
cat /tmp/adminhub-setup.err
```

## ⚡ Vorteile

- ✅ **Keine Berechtigungsdialoge** - Läuft ohne AppleScript
- ✅ **Automatisch** - Guest muss nichts machen
- ✅ **Persistent** - Überlebt Guest-Logout
- ✅ **Schnell** - Tools in wenigen Sekunden bereit
- ✅ **Zuverlässig** - Funktioniert bei jedem Login

## 🏫 Für Schulen

Perfekt für Informatik-Unterricht:
- Schüler können sofort loslegen
- Keine Admin-Rechte nötig
- Keine Installation auf Schüler-Accounts
- Automatische Bereinigung nach Logout

## 📝 Lizenz & Kontakt

Entwickelt für das Lessing-Gymnasium Karlsruhe.
Bei Fragen: IT-Administration kontaktieren

---

**Tipp:** Nach der Installation als Guest-User einloggen und testen! 
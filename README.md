# AdminHub

<p align="center">
  <img src="https://img.shields.io/badge/macOS-10.14+-blue?style=flat-square&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Python-3.x-green?style=flat-square&logo=python" alt="Python">
  <img src="https://img.shields.io/badge/Node.js-Latest-green?style=flat-square&logo=node.js" alt="Node.js">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License">
</p>

<p align="center">
  <strong>🚀 Automatische Entwicklertools für macOS Guest-Accounts</strong><br>
  <em>Entwickelt für das Lessing-Gymnasium Karlsruhe</em>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#verwendung">Verwendung</a> •
  <a href="#technologie">Technologie</a> •
  <a href="#lizenz">Lizenz</a>
</p>

---

## 📋 Übersicht

AdminHub ist ein automatisiertes System zur Bereitstellung von Entwicklertools für Guest-Accounts auf macOS. Es wurde speziell für Bildungseinrichtungen entwickelt, wo Schüler temporären Zugriff auf Programmiertools benötigen, ohne permanente Installationen vorzunehmen.

### 🎯 Problem & Lösung

**Problem:** Guest-Accounts auf macOS verlieren alle Daten beim Logout. Schüler müssen Tools jedes Mal neu installieren.

**Lösung:** AdminHub installiert Tools persistent im System und stellt sie automatisch jedem Guest zur Verfügung - ohne Benutzerinteraktion!

## ✨ Features

- **🚀 Automatisch** - Terminal öffnet sich beim Guest-Login mit allen Tools bereit
- **🔒 Keine Berechtigungsdialoge** - Läuft komplett ohne AppleScript-Permissions
- **⚡ Schnell** - Tools in Sekunden verfügbar
- **🎓 Bildungsfreundlich** - Perfekt für Informatik-Unterricht
- **🛠️ Vollständig** - Python, Git, Node.js, npm, jq, wget vorinstalliert
- **🌍 Deutsch** - Komplette deutsche Benutzeroberfläche

## 📦 Enthaltene Tools

| Tool | Version | Beschreibung |
|------|---------|--------------|
| **Python 3** | System | Programmiersprache mit pip3 |
| **Git** | Latest | Versionskontrolle |
| **Node.js** | Latest | JavaScript Runtime |
| **npm** | Latest | Node Package Manager |
| **jq** | Latest | JSON Prozessor |
| **wget** | Latest | Datei-Downloader |

## 🚀 Installation

### Voraussetzungen

- macOS 10.14 oder neuer
- Admin-Zugriff
- [Homebrew](https://brew.sh) installiert
- Guest-Account aktiviert (Systemeinstellungen → Benutzer & Gruppen)

### Schnellinstallation

```bash
# Repository klonen
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub

# Installation ausführen (als Admin)
sudo ./setup.sh
```

Bei der Frage "Soll ich die fehlenden Tools jetzt installieren?" mit **j** antworten.

**Das war's!** Die Installation ist vollständig automatisiert.

### Was passiert bei der Installation?

1. ✅ Entwicklertools werden nach `/opt/admin-tools/` installiert
2. ✅ LaunchAgent wird für automatischen Start konfiguriert
3. ✅ Setup-Scripts werden in `/usr/local/bin/` platziert
4. ✅ Berechtigungen werden korrekt gesetzt

## 💻 Verwendung

### Für Administratoren

Nach der Installation ist kein weiterer Eingriff nötig. Das System läuft vollautomatisch.

**Installation testen:**
```bash
./test.sh
```

**System-Status prüfen:**
```bash
# LaunchAgent Status
launchctl list | grep adminhub

# Installierte Tools
ls -la /opt/admin-tools/bin/
```

**Deinstallation:**
```bash
sudo ./uninstall.sh
```

### Für Schüler/Guest-User

1. Als **Guest** einloggen
2. Terminal öffnet sich automatisch
3. Alle Tools sind sofort verfügbar!

```bash
# Beispiele
python3 --version
git clone https://github.com/beispiel/projekt.git
npm install express
wget https://example.com/datei.zip
echo '{"name":"test"}' | jq .
```

## 🏗️ Technische Details

### Architektur

```
AdminHub/
├── setup.sh                 # Haupt-Installer
├── test.sh                  # Installations-Test  
├── uninstall.sh            # Deinstallation
├── scripts/
│   ├── install/            # Installations-Logik
│   ├── setup/              # Konfigurations-Scripts
│   ├── runtime/            # Laufzeit-Scripts
│   └── utils/              # Hilfsfunktionen
├── launchagents/           # macOS LaunchAgents
├── docs/                   # Dokumentation
└── LICENSE                 # MIT Lizenz
```

### Funktionsweise

1. **Persistente Installation**: Tools werden in `/opt/admin-tools/` installiert
2. **LaunchAgent**: `com.adminhub.guestsetup` startet bei jedem Guest-Login
3. **Shell-Integration**: Automatische PATH-Konfiguration via `.zshrc`
4. **Tool-Kopie**: Tools werden nach `/Users/Guest/tools/` kopiert
5. **Zero-Persistence**: Guest-spezifische Daten werden beim Logout gelöscht

### Sicherheit

- ✅ Keine Passwörter gespeichert
- ✅ Keine persönlichen Daten
- ✅ Read-only Zugriff für Guest-User
- ✅ Automatische Bereinigung beim Logout
- ✅ Keine sudo-Rechte für Guest erforderlich

## 🐛 Fehlerbehebung

### Terminal öffnet sich nicht

```bash
# LaunchAgent neu laden
sudo launchctl unload /Library/LaunchAgents/com.adminhub.guestsetup.plist
sudo launchctl load /Library/LaunchAgents/com.adminhub.guestsetup.plist
```

### Tools nicht verfügbar

Als Guest im Terminal:
```bash
# Manuell ausführen
source /usr/local/bin/guest_setup_auto.sh
```

### Logs prüfen

```bash
# Setup-Logs
cat /tmp/adminhub-setup.log
cat /tmp/adminhub-setup.err

# LaunchAgent Logs
tail -f /var/log/system.log | grep adminhub
```

### Komplette Neuinstallation

```bash
# Alles entfernen und neu installieren
sudo ./uninstall.sh
sudo ./setup.sh
```

## 🤝 Beitragen

Dieses Projekt wurde speziell für das Lessing-Gymnasium Karlsruhe entwickelt. Bei Interesse an Anpassungen oder Erweiterungen:

1. Fork erstellen
2. Feature Branch erstellen (`git checkout -b feature/NeuesFeature`)
3. Änderungen committen (`git commit -m 'Füge NeuesFeature hinzu'`)
4. Branch pushen (`git push origin feature/NeuesFeature`)
5. Pull Request erstellen

## 📄 Lizenz

Copyright © 2025 Luka Löhr

Dieses Projekt ist unter der MIT-Lizenz mit Namensnennung lizenziert. Bei jeder Nutzung muss der Copyright-Hinweis "© 2025 Luka Löhr" sichtbar angegeben werden.

Siehe [LICENSE](LICENSE) für Details.

## 🙏 Danksagung

Entwickelt für das **Lessing-Gymnasium Karlsruhe** zur Unterstützung des Informatik-Unterrichts.

---

<p align="center">
  <strong>© 2025 Luka Löhr</strong><br>
  <a href="https://github.com/luka-loehr/AdminHub">github.com/luka-loehr/AdminHub</a>
</p> 
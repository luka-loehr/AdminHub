# AdminHub - Guest Account Developer Tools

> 🎛️ Zentrale Steuerzentrale für Schul-MacBooks – Ein mächtiges GUI-Tool zur Fernverwaltung von 100+ Macs

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub

# 2. Run setup
sudo ./setup.sh

# 3. Enable permission-free Guest setup
sudo ./scripts/setup/setup_guest_shell_init.sh
```

## 🚀 Überblick

AdminHub ist eine native macOS-Anwendung zur zentralen Verwaltung und Steuerung von MacBooks in Schulumgebungen. Das Tool ermöglicht die Installation von Entwicklungstools, Remote-Zugriff und automatisierte Wartung über eine intuitive grafische Oberfläche.

### Kernfunktionen

- **🔧 Remote Dev-Tools**: Zero-Persistence Installation von Entwicklungstools für Guest-Accounts
- **📡 Auto-Discovery**: Automatische Erkennung aller Macs im Netzwerk
- **💻 Multi-Terminal**: Gleichzeitiger SSH-Zugriff auf mehrere Systeme
- **🔄 Bulk-Operations**: Updates und Maintenance für beliebig viele Macs gleichzeitig
- **🏗️ Modular**: Einfache Erweiterung um neue Tools und Funktionen

## 🏗️ Architektur

```
┌─────────────────┐         ┌─────────────────┐
│   AdminHub      │         │  Mac Client     │
│  (SwiftUI App)  │◄────────┤  - Responder    │
│  - SQLite DB    │  JSON   │  - SSH Server   │
│  - Discovery    │  /TLS   │  - LaunchDaemon │
└─────────────────┘         └─────────────────┘
```

### Komponenten

1. **AdminHub** (Hauptanwendung)
   - SwiftUI-basierte macOS App
   - SQLite Datenbank für Geräteverwaltung
   - Broadcast-Discovery für Netzwerk-Scan

2. **Responder** (Client-Daemon)
   - Lightweight Swift Daemon auf jedem verwalteten Mac
   - Automatische SSH-Key Verwaltung
   - Status-Reporting und Command-Execution

## 🛠️ Geplante Features

- [x] Tech-Stack: Swift/SwiftUI
- [x] Datenbank: SQLite
- [x] Auto-Discovery Konzept
- [ ] Responder-Protokoll Implementation
- [ ] GUI Grundgerüst
- [ ] SSH-Integration
- [ ] Tool-Management System
- [ ] Guest-Account Integration

## 📋 Dokumentation

Detaillierte Planungen und Entscheidungen finden sich in [`todo.md`](todo.md).

## 🔒 Sicherheit

- SSH-Key basierte Authentifizierung
- Verschlüsselte Kommunikation (TLS)
- Nur innerhalb des Schulnetzwerks nutzbar
- Keine Passwörter im Klartext

## 🚧 Status

**Aktuell in der Planungsphase** – Kein produktiver Code vorhanden.

## 📄 Lizenz

Privates Projekt für Schulzwecke.

## How It Works (Permission-Free!)

The system now works without any Apple permission dialogs:

1. **LaunchAgent** (`com.adminhub.guestsetup`) runs at every Guest login
2. **Login Setup Script** creates `.zshrc` and `.bash_profile` in the fresh Guest home
3. **Auto Setup Script** runs when Terminal opens and sets up the tools
4. **No AppleScript** = No permission dialogs! 🎉

### Key Components:

- `/Library/LaunchAgents/com.adminhub.guestsetup.plist` - Runs at Guest login
- `/usr/local/bin/guest_login_setup` - Creates shell config files
- `/usr/local/bin/guest_setup_auto.sh` - Sets up tools when Terminal opens
- `/opt/admin-tools/` - Persistent tool storage (survives Guest logout)

---

*Entwickelt für die zentrale Verwaltung von Schul-MacBooks mit Fokus auf Benutzerfreundlichkeit und Sicherheit.* 
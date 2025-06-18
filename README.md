# AdminHub

> 🎛️ Zentrale Steuerzentrale für Schul-MacBooks – Ein mächtiges GUI-Tool zur Fernverwaltung von 100+ Macs

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

---

*Entwickelt für die zentrale Verwaltung von Schul-MacBooks mit Fokus auf Benutzerfreundlichkeit und Sicherheit.* 
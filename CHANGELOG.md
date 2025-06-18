# Changelog

Alle bemerkenswerten Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-18

### 🎉 Erste stabile Version

#### Hinzugefügt
- Vollautomatische Installation von Entwicklertools für macOS Guest-Accounts
- Unterstützung für Python 3, Git, Node.js, npm, jq und wget
- LaunchAgent für automatisches Terminal-Öffnen beim Guest-Login
- Berechtigungsfreies System ohne AppleScript-Dialoge
- Komplette deutsche Lokalisierung
- Umfassende Dokumentation und README
- MIT-Lizenz mit Namensnennung
- Automatische Tool-Installation via Homebrew
- Fehlerbehandlung und Logging
- Deinstallations-Script

#### Technische Details
- Tools werden in `/opt/admin-tools/` persistent installiert
- Guest-spezifische Kopie in `/Users/Guest/tools/`
- LaunchAgent: `com.adminhub.guestsetup`
- Shell-Integration via `.zshrc` und `.bash_profile`
- Kompatibel mit macOS 10.14+

#### Bekannte Einschränkungen
- Benötigt Homebrew für die Installation
- Guest-Account muss in macOS aktiviert sein
- Admin-Rechte für die Erstinstallation erforderlich

---

© 2025 Luka Löhr 
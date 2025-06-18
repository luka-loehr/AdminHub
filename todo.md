# AdminHub – Zentrale Steuerzentrale für Schul-MacBooks

## 📋 Projektstatus: Planungsphase

---

## 🎯 Projektziel

AdminHub ist ein Remote-Power-Tool mit grafischer Oberfläche zur zentralen Verwaltung von über 100 MacBooks in einer Schulumgebung.

### Kernfunktionen:
1. **Remote Dev-Tools** (Zero-Persistence für Guest-Accounts)
2. **Zentrale Updates & Maintenance** (Multi-Select für beliebig viele Systeme)
3. **Terminal-Fernzugriff** (automatischer SSH-Login ohne Passwort)
4. **Modulare Erweiterbarkeit** (neue Tools und Aktionen leicht integrierbar)

---

## 🏗️ Architektur-Planung

### [x] Tech-Stack Entscheidung: **Swift/SwiftUI**
- Native macOS Performance
- Beste System-Integration
- Moderne UI mit SwiftUI
- Direkter Zugriff auf macOS APIs

### [ ] AdminHub Responder (Client-Component)
- [ ] Lightweight Swift daemon auf jedem Mac
- [ ] Lauscht auf Broadcast/Multicast für Discovery
- [ ] Handled SSH-Key Exchange automatisch
- [ ] Meldet System-Info (Hostname, IP, Status)
- [ ] LaunchDaemon für Auto-Start
- [ ] Secure Communication Protocol definieren

### [ ] SSH-Verbindung zu Schul-MacBooks
- [ ] SSH-Key-basierte Authentifizierung einrichten
- [ ] Admin-Account Zugangsdaten sicher verwalten
- [ ] Verbindungspool für parallele Operationen?
- [ ] Timeout-Handling und Reconnect-Strategien

### [x] Geräte-Verwaltung
- [x] **SQLite** als lokale Datenbank
- [ ] Schema Design:
  ```
  Devices: id, hostname, ip_address, mac_address, last_seen, status, group_id
  Groups: id, name, description
  Actions: id, device_id, action_type, timestamp, status, log
  Tools: id, name, version, install_path, size
  DeviceTools: device_id, tool_id, installed_date
  ```
- [x] **Automatisches Discovery** via Responder
  - Beim Start: Broadcast im Netzwerk
  - Responder antworten mit ihrer Info
  - UI zeigt alle gefundenen Macs
  - Admin wählt aus, welche verwaltet werden
- [ ] Import/Export als JSON für Backup

### [ ] GUI-Design
- [x] Framework: **SwiftUI**
- [ ] Framework-Entscheidung (Tkinter vs PyQt vs Electron vs Flutter?)
- [ ] Hauptkomponenten:
  - [ ] Geräteliste mit Multi-Select
  - [ ] Statusanzeige (online/offline/busy)
  - [ ] Action-Buttons (Update, Install, Terminal öffnen)
  - [ ] Log-Bereich für Ausgaben
  - [ ] Fortschrittsbalken für Bulk-Operationen
- [ ] Dark/Light Mode?
- [ ] Responsive für verschiedene Bildschirmgrößen?

---

## 🛠️ Tool-Management

### [ ] Installation im Admin-Account
- [ ] Installationsort festlegen (z.B. `/opt/admin-tools/`)
- [ ] Homebrew als Package Manager nutzen?
- [ ] Versionsverwaltung der Tools
- [ ] Update-Mechanismen

### [ ] Guest-Account Integration
- [ ] Kopier-Mechanismus planen (rsync vs cp vs custom)
- [ ] Zielverzeichnis im Guest-Home (z.B. `~/DevTools/`)
- [ ] PATH-Variable temporär anpassen
- [ ] Cleanup beim Logout sicherstellen

### [ ] Login/Logout Hooks
- [ ] LaunchAgent vs Login-Hook evaluieren
- [ ] Skript für Tool-Kopierung schreiben
- [ ] Skript für Cleanup schreiben
- [ ] Fehlerbehandlung wenn Kopieren fehlschlägt

---

## 🖥️ Terminal-Fernzugriff

### [ ] Automatisches Terminal öffnen
- [ ] `osascript` + `Terminal.app` Ansatz testen
- [ ] Alternative: iTerm2 Integration?
- [ ] SSH-Command mit korrekten Parametern
- [ ] Mehrere Terminals gleichzeitig verwalten
- [ ] Tab-basiert vs separate Fenster?

### [ ] SSH-Konfiguration
- [ ] `.ssh/config` optimal einrichten
- [ ] ControlMaster für Performance?
- [ ] StrictHostKeyChecking Strategie
- [ ] Keepalive-Settings

---

## 🔒 Sicherheit

### [ ] Responder Security
- [ ] Signierte Kommunikation zwischen AdminHub und Responder
- [ ] Whitelist für erlaubte AdminHub Instanzen?
- [ ] Rate Limiting für Requests
- [ ] Verschlüsselte Kommunikation (TLS?)

### [ ] Authentifizierung
- [ ] SSH-Key Management (wo speichern?)
- [ ] Keine Klartext-Passwörter!
- [ ] Berechtigungskonzept für AdminHub selbst?

### [ ] Netzwerk
- [x] Nur innerhalb des Schul-Netzwerks nutzbar
- [ ] Responder nur auf private IPs reagieren lassen
- [ ] VPN-Überlegungen?
- [ ] Firewall-Regeln dokumentieren

### [ ] Audit & Logging
- [ ] Alle Aktionen protokollieren
- [ ] Wer hat wann was gemacht?
- [ ] Log-Rotation

---

## 🔧 Technische Entscheidungen

### [x] Programmiersprache & Stack
- **AdminHub**: Swift + SwiftUI (macOS App)
- **Responder**: Swift (Lightweight Daemon)
- **Datenbank**: SQLite (Core Data?)
- **Kommunikation**: Bonjour/mDNS für Discovery + Custom Protocol

### [x] Datenbank/Storage
- **SQLite** für Geräte, Logs und Konfiguration
- Core Data für einfache Swift Integration?
- JSON für Import/Export
- Keychain für sensitive Daten (SSH Keys)

### [ ] Plattform-Kompatibilität
- [ ] Minimum macOS Version?
- [ ] Intel + Apple Silicon Support
- [ ] Abhängigkeiten minimieren

---

## 🚀 Erweiterbarkeit

### [ ] Plugin-System
- [ ] Wie können neue Tools hinzugefügt werden?
- [ ] YAML/JSON-basierte Tool-Definitionen?
- [ ] Custom Scripts einbinden?

### [ ] API/CLI
- [ ] REST API für Automatisierung?
- [ ] CLI-Interface zusätzlich zur GUI?
- [ ] Webhook-Support für Events?

### [ ] Konfiguration
- [ ] Zentrale Config-Datei
- [ ] Environment-spezifische Overrides
- [ ] Hot-Reload von Konfig-Änderungen?

---

## 📝 Nächste Schritte

1. ~~**Framework-Entscheidung treffen**~~ ✅ Swift/SwiftUI
2. **Responder-Protokoll** designen
3. **DB Schema** finalisieren
4. **Discovery Mechanismus** (Bonjour vs Custom Broadcast)
5. **Proof of Concept**: 
   - Simple SwiftUI App
   - SQLite Integration
   - Responder Daemon
   - Discovery Test

---

## 💡 Offene Fragen

- Wie installieren wir den Responder auf 100+ Macs? (MDM? Script?)
- Port für Responder-Kommunikation?
- Wie updaten wir den Responder selbst?
- Wie viele gleichzeitige SSH-Verbindungen sind realistisch?
- Sollen Updates gestaffelt oder parallel laufen?
- Brauchen wir eine Queue für Aktionen?
- Wie gehen wir mit offline Geräten um?
- Backup-Strategie für die Tool-Installations?
- Integration mit bestehenden MDM-Lösungen?

---

## 📅 Meeting-Notizen & Entscheidungen

### [Datum] - Projekt-Kickoff
- AdminHub Konzept definiert
- Keine Code-Implementierung ohne Absprache
- todo.md als zentrale Dokumentation etabliert

### [Heute] - Architektur-Entscheidungen
- **Tech-Stack**: Swift/SwiftUI für native macOS App
- **Datenbank**: SQLite für lokale Datenhaltung
- **Discovery**: Automatisch via Netzwerk-Scan beim Start
- **Responder**: Daemon auf jedem Mac für schnelle Verbindungen
- Nur nutzbar im sicheren Schulnetzwerk

---

## 🧠 Brainstorming & Design-Details

### Responder-AdminHub Kommunikationsprotokoll

#### Discovery Phase
```
1. AdminHub startet → Broadcast: "ADMINHUB_DISCOVER" auf Port 8765
2. Responder empfängt → Antwortet mit:
   {
     "type": "RESPONDER_ANNOUNCE",
     "hostname": "mac-labor-01",
     "ip": "192.168.1.101", 
     "mac": "AA:BB:CC:DD:EE:FF",
     "responder_version": "1.0.0",
     "os_version": "14.2.1",
     "available_space": "125GB",
     "admin_user": "schuladmin",
     "ssh_port": 22,
     "responder_port": 8765,
     "capabilities": ["ssh", "file_transfer", "tool_install", "guest_management"]
   }
3. AdminHub speichert in SQLite
```

#### Authentifizierung & Pairing
```
1. AdminHub → Responder: "REQUEST_PAIRING"
2. Responder generiert Pairing-Code (auf Mac Display?)
3. Admin gibt Code in AdminHub ein
4. Key Exchange:
   - AdminHub sendet public key
   - Responder speichert key in authorized_keys
   - Responder sendet eigenen public key zurück
5. Verschlüsselte Verbindung etabliert
```

#### Command Protocol
```
{
  "id": "uuid-v4",
  "type": "COMMAND",
  "action": "install_tools",
  "params": {
    "tools": ["python3", "git", "nodejs"],
    "target_path": "/opt/admin-tools/"
  },
  "auth_token": "jwt-token"
}
```

### Tool-Kopier-Mechanismus für Guest

#### Variante A: LaunchAgent
```bash
# /Library/LaunchAgents/com.school.devtools.plist
- Triggered bei Login
- Prüft ob User = Guest
- Kopiert Tools von /opt/admin-tools/ → /Users/Guest/DevTools/
- Setzt PATH Variable
- Registriert Cleanup für Logout
```

#### Variante B: Login Hook (deprecated aber funktioniert)
```bash
# /usr/local/bin/guest-tool-setup.sh
- Einfacher, direkter
- Weniger macOS "magic"
```

### Responder Deployment Strategien

1. **MDM Push** (wenn vorhanden)
   - Package (.pkg) mit Responder + LaunchDaemon
   - Automatische Installation
   
2. **USB-Stick Masseninstallation**
   - Installer-App die durchs Labor läuft
   - QR-Code für Download aus lokalem Server?
   
3. **ARD (Apple Remote Desktop)**
   - Falls Schule das hat
   - Script remote ausführen

### GUI Design Konzepte

#### Hauptfenster
```
┌─────────────────────────────────────────┐
│ AdminHub           [🔍 Suche] [⚙️] [🔄]  │
├─────────────────────────────────────────┤
│ ┌─────────┬─────────────────────────┐  │
│ │Gruppen  │ Mac Labor 1 (25 online) │  │
│ │         ├─────────────────────────┤  │
│ │▼Labor 1 │ □ mac-01  ● Python Git  │  │
│ │ Labor 2 │ □ mac-02  ● Python     │  │
│ │ Labor 3 │ ☑ mac-03  ○ Updating... │  │
│ │ Lehrer  │ ☑ mac-04  ● Alle Tools │  │
│ │+Gruppe  │ □ mac-05  ⚠️ Offline    │  │
│ └─────────┴─────────────────────────┘  │
│                                         │
│ [Terminal] [Tools →] [Update] [Herunterfahren] │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Log Output                          │ │
│ │ > Verbinde mit mac-03...           │ │
│ │ > Python 3.11 wird installiert...  │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### SSH Terminal Integration

#### Option 1: Embedded Terminal
- NSTextView mit PTY
- Direkt in AdminHub
- Pro: Alles in einer App
- Contra: Komplexer

#### Option 2: Terminal.app Integration
```swift
let script = """
tell application "Terminal"
    do script "ssh -o StrictHostKeyChecking=no schuladmin@\(hostname)"
end tell
"""
NSAppleScript(source: script)?.executeAndReturnError(nil)
```

#### Option 3: Custom Terminal Window
- Separates SwiftUI Window
- Nutzt Process() für SSH
- Mittlerer Weg

### Datenbank Schema (Detailliert)

```sql
-- Geräte
CREATE TABLE devices (
    id INTEGER PRIMARY KEY,
    hostname TEXT UNIQUE NOT NULL,
    ip_address TEXT,
    mac_address TEXT,
    group_id INTEGER,
    last_seen DATETIME,
    status TEXT CHECK(status IN ('online', 'offline', 'busy')),
    os_version TEXT,
    responder_version TEXT,
    notes TEXT,
    FOREIGN KEY (group_id) REFERENCES groups(id)
);

-- Tool-Definitionen
CREATE TABLE tools (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    display_name TEXT,
    install_command TEXT,
    check_command TEXT,
    version_command TEXT,
    estimated_size INTEGER,
    category TEXT
);

-- Installierte Tools pro Gerät
CREATE TABLE device_tools (
    device_id INTEGER,
    tool_id INTEGER,
    installed_date DATETIME,
    version TEXT,
    status TEXT,
    PRIMARY KEY (device_id, tool_id)
);

-- Geplante/Ausgeführte Aktionen
CREATE TABLE actions (
    id INTEGER PRIMARY KEY,
    device_id INTEGER,
    action_type TEXT,
    parameters JSON,
    scheduled_at DATETIME,
    started_at DATETIME,
    completed_at DATETIME,
    status TEXT,
    log TEXT,
    error TEXT
);

-- Konfig für Guest-Tools
CREATE TABLE guest_tools_config (
    id INTEGER PRIMARY KEY,
    source_path TEXT,
    dest_path TEXT,
    cleanup_on_logout BOOLEAN,
    add_to_path BOOLEAN
);
```

### Sicherheitskonzepte

1. **Responder Härtung**
   - Nur bestimmte Commands erlaubt
   - Rate Limiting
   - Fail2Ban ähnliche Logik
   - Logging aller Aktionen

2. **AdminHub Authentifizierung**
   - Optional: LDAP/AD Integration?
   - Oder: Lokale Admin-Accounts
   - 2FA für kritische Aktionen?

3. **Verschlüsselung**
   - TLS für Responder-Kommunikation
   - Ed25519 Keys für SSH
   - Keychain für Key-Storage

### Tool-Installation Flow

```
1. Admin wählt Tools + Macs aus
2. AdminHub → Responder: "INSTALL_TOOLS"
3. Responder:
   - Prüft ob Tool schon da (cache)
   - Lädt herunter (brew/curl/git)
   - Installiert in /opt/admin-tools/
   - Symlinks erstellen
   - Status Updates → AdminHub
4. AdminHub zeigt Progress
5. Nach Completion: Guest-Config update
```

### Erweiterungsideen

1. **Monitoring Dashboard**
   - CPU/RAM/Disk Nutzung live
   - Welche Apps laufen?
   - Netzwerk-Traffic?

2. **Scheduled Actions**
   - "Jeden Freitag 18:00 Updates"
   - "Herunterfahren um 22:00"

3. **Template System**
   - "Labor-Standard": Python, Git, VS Code
   - "Kunst-Macs": Photoshop, Blender
   - Ein Klick → Alle Tools

4. **Backup/Restore**
   - Config exportieren
   - Disaster Recovery

---

## 🤔 Kritische Designfragen

1. **Responder Update-Mechanismus**
   - Self-Update fähig?
   - Oder: AdminHub pushed Updates?
   - Rollback bei Fehler?

2. **Offline-Fähigkeit**
   - Was wenn Mac offline während Action?
   - Queue auf Responder-Seite?
   - Retry-Logik?

3. **Multi-Admin Support**
   - Mehrere AdminHub Instanzen?
   - Wer darf was?
   - Konflikt-Resolution?

4. **Performance bei 100+ Macs**
   - Parallel vs Sequential Operations
   - Batching von Commands
   - Progress Aggregation

5. **Guest Tool Cleanup**
   - Was wenn Guest nicht sauber ausloggt?
   - Cron Job als Backup?
   - Disk Space Monitoring?

---

## 🐛 Bekannte Herausforderungen

- Guest-Account hat eingeschränkte Rechte
- macOS Security Features (Gatekeeper, SIP)
- Netzwerk-Latenz bei 100+ Geräten
- Verschiedene macOS Versionen im Einsatz?
- **NEU**: Responder-Installation auf allen Macs
- **NEU**: Firewall-Regeln für Responder-Port

---

## 📧 E-Mail Entwurf an Herrn Roth

**Betreff:** AdminHub Update - Konzept steht, ein paar Fragen noch

Hallo Herr Roth,

wie besprochen habe ich über die Ferien am AdminHub-Projekt gearbeitet. Das Konzept steht jetzt und die Umsetzung ist definitiv bis zum nächsten Schuljahr machbar.

**Kurzer Status:**
- Tech-Stack steht fest: Swift/SwiftUI für die Admin-App + ein kleiner Responder-Daemon auf jedem Mac
- Die App erkennt automatisch alle Macs im Netzwerk und ermöglicht Multi-Select für Bulk-Operations
- Tools werden für Guest-Accounts temporär verfügbar gemacht (Zero-Persistence)
- Remote-Terminal Zugriff auf mehrere Macs gleichzeitig

Ich weiß, Sie hatten anfangs eine einfachere Version im Kopf. Das wäre auch schnell gemacht, aber ich denke, es lohnt sich, gleich etwas Vernünftiges zu bauen - besonders wenn später neue Tools oder Features dazukommen sollen. Die paar Wochen Extra-Aufwand zahlen sich aus.

**Was ich von Ihnen bräuchte:**

1. **Wie bekomme ich den Responder auf alle Macs?**
   - Haben wir MDM? Apple Remote Desktop?
   - Oder muss ich mit USB-Stick durch die Labore laufen?

2. **Netzwerk-Details:**
   - Ist SSH auf den Macs aktiviert?
   - Welchen Port kann ich für den Responder nutzen?

3. **Guest-Account Setup:**
   - Wie sind die aktuell konfiguriert?
   - Wird das Home-Verzeichnis beim Logout gelöscht?

4. **Welche Tools sollen rein?**
   - Python, Git sind klar - was noch?
   - Homebrew oder direkte Installation?

Die komplette Planung liegt auf GitHub: https://github.com/luka-loehr/AdminHub

Können wir uns mal kurz zusammensetzen und die Details klären? Dann kann ich richtig loslegen.

Viele Grüße  
[Dein Name]

---

## 🚀 Vereinfachte Version - Implementierung

### [Heute] - Erste funktionierende Version
- **Erstellt**: `guest_tools_setup.sh` - Bash-Script für Guest-Tools-Management
- **Features**:
  - Installiert Tools über Homebrew in Admin-Space
  - Kopiert Tools automatisch für Guest-Account
  - LaunchAgent für automatisches Setup beim Login
  - Terminal öffnet sich automatisch für Guest mit Live-Progress
  - Cleanup-Funktion beim Logout
  
### Implementierte Komponenten:
1. **guest_tools_setup.sh** - Hauptscript für Tool-Management
2. **open_guest_terminal.sh** - Öffnet Terminal für Guest
3. **com.adminhub.guesttools.plist** - LaunchAgent für Tool-Installation
4. **com.adminhub.guestterminal.plist** - LaunchAgent für Terminal-Anzeige

### Implementierte Befehle:
```bash
# Tools im Admin-Space installieren (benötigt sudo)
sudo ./guest_tools_setup.sh install-admin

# LaunchAgent für Auto-Setup erstellen (benötigt sudo) 
sudo ./guest_tools_setup.sh create-agent

# Tools für Guest einrichten
./guest_tools_setup.sh setup

# Tools vom Guest entfernen
./guest_tools_setup.sh cleanup

# Aktuellen Status testen
./guest_tools_setup.sh test
```

### Was beim Guest-Login passiert:
1. Terminal öffnet sich automatisch
2. Zeigt "AdminHub Guest Tools Setup" Banner
3. Live-Installation aller Tools mit Progress-Anzeige
4. Übersichtliche Tool-Liste mit Icons und Versionen
5. Wartet auf Tastendruck bevor Terminal bereit ist

### Installierte Tools:
- 🐍 Python 3 + pip3
- 📚 Git
- 📗 Node.js + npm  
- 🔧 jq (JSON processor)
- 📥 wget (Download tool)

### Nächste Schritte für Test:
1. [x] Script als Admin ausführen: `sudo ./guest_tools_setup.sh install-admin`
2. [x] LaunchAgent installieren: `sudo ./guest_tools_setup.sh create-agent`
3. [ ] Als Guest-User einloggen und testen
4. [ ] Logout-Cleanup verifizieren 

## Recent Updates

### Permission-Free Terminal Setup (Implemented)
- ✅ Created `guest_setup_auto.sh` - runs from shell init instead of AppleScript
- ✅ Created `setup_guest_shell_init.sh` - configures .zshrc/.bash_profile
- ✅ No more Apple permission dialogs!
- ✅ Works in already-open Terminal window
- ✅ Removes old LaunchAgent automatically

### Next Steps
- [ ] Test the new setup on a fresh Guest account
- [ ] Update main install script to use new method by default
- [ ] Consider removing old AppleScript-based scripts 
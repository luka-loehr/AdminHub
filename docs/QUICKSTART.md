# AdminHub Schnellstart-Anleitung

## 🚀 In 3 Minuten startklar!

### 1️⃣ Installation (einmalig als Admin)

```bash
# Repository klonen
git clone https://github.com/luka-loehr/AdminHub.git
cd AdminHub

# Alles installieren
sudo ./setup.sh

# Installation testen
./test.sh
```

### 2️⃣ Verwendung (als Guest-User)

1. **Abmelden** und als **Guest** einloggen
2. **Terminal öffnet sich automatisch**
3. **Fertig!** Alle Tools sind verfügbar

### 📋 Verfügbare Tools

```bash
python3 --version    # Python mit pip
git --version       # Git Versionskontrolle  
node --version      # Node.js
npm --version       # Node Package Manager
jq --version        # JSON Processor
wget --version      # Datei-Downloader
```

### 🆘 Schnelle Hilfe

**Terminal öffnet sich nicht?**
```bash
# Als Admin ausführen:
sudo launchctl load /Library/LaunchAgents/com.adminhub.guestsetup.plist
```

**Tools nicht verfügbar?**
```bash
# Im Guest-Terminal ausführen:
source /usr/local/bin/guest_setup_auto.sh
```

**Komplette Neuinstallation?**
```bash
sudo ./uninstall.sh  # Alles entfernen
sudo ./setup.sh      # Neu installieren
```

### ✨ Das war's schon!

Keine Berechtigungsdialoge, keine Wartezeit - einfach loslegen! 
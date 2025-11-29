# 🧰 Docker Stack Restore Script

Ein sicheres, interaktives Restore-Tool für Docker-Stacks, die mit dem  
[Docker Stack Backup Script](../docker_backup.sh) gesichert wurden.

---

## 🚀 Übersicht

Dieses Skript ermöglicht das **manuelle, aber geführte Wiederherstellen** von Docker-Stacks aus den erzeugten Backup-Archiven.  
Es ist bewusst **nicht automatisiert**, um maximale Kontrolle und Sicherheit bei der Wiederherstellung zu gewährleisten.

### Features

- 🔍 **Automatische Erkennung** von verfügbaren Backups  
- 📦 **Interaktive Auswahl** des gewünschten Backups  
- ⚙️ **Sicheres Entpacken** in den richtigen Stack-Pfad  
- 🧱 **Optionale Wiederherstellung** persistenter Daten  
- 🧩 **Kein automatischer Start** der Container (bewusste Kontrolle)  
- 🛡️ **Überschreib-Bestätigung**, falls der Zielstack bereits existiert  
- 💬 **Einfache CLI-Ausgabe** mit klaren Hinweisen

---

## 📁 Projektstruktur

Typischer Aufbau deines Systems:

```
/opt/
├── stacks/
│   ├── nextcloud/
│   ├── traefik/
│   └── portainer/
├── docker_backups/
│   ├── nextcloud_2025-10-13_03-00-00.tar.gz
│   └── traefik_2025-10-13_03-00-00.tar.gz
└── scripts/
    ├── docker_backup.sh
    ├── docker_backup.conf
    └── docker_restore.sh
```

---

## ⚙️ Installation

1. Skript ablegen unter  
   ```bash
   /opt/scripts/docker_restore.sh
   ```

2. Ausführbar machen:  
   ```bash
   chmod +x /opt/scripts/docker_restore.sh
   ```

3. Sicherstellen, dass die `docker_backup.conf` im selben Verzeichnis liegt.

---

## 📜 Beispielkonfiguration (`docker_backup.conf`)

> Diese Datei wird sowohl vom Backup- als auch vom Restore-Skript verwendet.

```bash
# =============================================================================
# Docker Stack Backup Configuration
# =============================================================================

STACKS_DIR="/opt/stacks"
BACKUP_DIR="/opt/docker_backups"
LOG_DIR="/var/log/docker_backups"
RETENTION_DAYS=30
LOG_RETENTION_DAYS=14
INCLUDE_DATA=true
SKIP_STOP=("traefik" "portainer" "watchtower")
```

---

## 🧾 Verwendung

Starte das Restore-Tool manuell mit `sudo`, um sicherzustellen,  
dass du Zugriff auf alle Pfade und Container hast:

```bash
sudo bash /opt/scripts/docker_restore.sh
```

Danach folgt eine geführte Abfrage:

1. Auswahl eines vorhandenen Backup-Archivs  
2. Bestätigung, ob ein vorhandener Stack überschrieben werden soll  
3. Optionales Wiederherstellen der persistenten Daten  
4. Abschlussmeldung mit Hinweisen zum manuellen Start

---

## 💻 Beispielausgabe

```
🧰 Docker Stack Restore Tool
📦 Available backups in: /opt/docker_backups
[1] nextcloud_2025-10-13_03-00-00.tar.gz
[2] portainer_2025-10-06_03-00-00.tar.gz

Select backup number to restore: 1
📁 Stack name detected: nextcloud
📍 Target restore path: /opt/stacks/nextcloud
⚠️  Target directory already exists. Overwrite existing files? (y/N): y
Restore persistent data as well? (y/N): y
✅ Restore complete for stack: nextcloud
Next steps:
  cd "/opt/stacks/nextcloud"
  docker compose up -d
```

---

## 🧱 Ablaufbeschreibung

| Schritt | Beschreibung |
|----------|---------------|
| 1️⃣ | Liste aller `.tar.gz`-Backups im `BACKUP_DIR` anzeigen |
| 2️⃣ | Nutzer wählt ein Backup aus |
| 3️⃣ | Stack-Name wird automatisch aus dem Dateinamen erkannt |
| 4️⃣ | Archiv wird entpackt und Stack-Dateien ins Ziel kopiert |
| 5️⃣ | (Optional) Data-Archiv wird entpackt |
| 6️⃣ | Nutzer startet den Stack manuell mit `docker compose up -d` |

---

## ⚠️ Sicherheitshinweise

- Das Skript **startet keine Container automatisch**.  
  Du entscheidest bewusst, wann der Stack hochgefahren wird.
- Bei existierenden Stacks erfolgt eine **Sicherheitsabfrage**, bevor Dateien überschrieben werden.
- Überprüfe nach dem Restore die `.env`- und `compose.yaml`-Dateien auf korrekte Pfade oder Mounts.
- Bei Datenbanken (z. B. MariaDB, PostgreSQL) empfiehlt sich ein **gesonderter Datenbank-Dump-Restore**, falls du nur Teile wiederherstellen willst.

---

## 🧩 Beispiel: Manueller Start nach Restore

Nach erfolgreichem Restore:

```bash
cd /opt/stacks/nextcloud
docker compose up -d
```

---

## 🧰 Troubleshooting

| Problem | Ursache | Lösung |
|----------|----------|--------|
| „Configuration file not found“ | `docker_backup.conf` fehlt oder Pfad falsch | Pfad prüfen, ggf. kopieren |
| „No backups found“ | Noch keine Sicherungen vorhanden | Backup-Skript ausführen |
| Daten fehlen nach Restore | Persistente Daten wurden nicht wiederhergestellt | Beim Restore „y“ bestätigen oder manuell entpacken |
| Permission denied | Skript ohne Root-Rechte gestartet | `sudo` verwenden |

---

## 🧾 Lizenz

Dieses Projekt steht unter der MIT-Lizenz.  
Weitere Infos siehe [LICENSE](./LICENSE).

---

## 🧠 Tipps

- Führe nach einem Restore stets `docker compose config` aus,  
  um sicherzustellen, dass deine Compose-Datei valide ist.
- Erstelle nach größeren Änderungen am Stack ein neues Backup.
- Dokumentiere, welche Container in der Skip-Liste stehen, um sie bei Bedarf manuell zu sichern.

---

## 📜 Änderungsverlauf

| Version | Datum | Änderung |
|----------|--------|-----------|
| 1.0 | 2025-10-13 | Initiale Version des Restore-Skripts |

---

**Autor:** Stefan  
**Kompatibel mit:** Docker Backup Script v1.8

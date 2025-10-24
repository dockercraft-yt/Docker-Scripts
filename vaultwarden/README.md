# 🧱 Vaultwarden Backup Script (für Unraid)

Dieses Script erstellt automatisiert Backups deiner **Vaultwarden-Installation** (z. B. auf Unraid).  
Es stoppt den Container, sichert die AppData in ein komprimiertes `.tar.gz`‑Archiv, startet Vaultwarden neu und löscht alte Backups.

---

- [🧱 Vaultwarden Backup Script (für Unraid)](#-vaultwarden-backup-script-für-unraid)
  - [🚀 Funktionen](#-funktionen)
  - [⚙️ Voraussetzungen](#️-voraussetzungen)
  - [🧩 Scriptinhalt](#-scriptinhalt)
  - [📄 Dateistruktur](#-dateistruktur)
  - [🕐 Automatisierung mit Cron](#-automatisierung-mit-cron)
  - [🧪 Wiederherstellung (Restore)](#-wiederherstellung-restore)
  - [💡 Tipps](#-tipps)

## 🚀 Funktionen

- Stoppt den Vaultwarden‑Docker‑Container während des Backups  
- Erstellt ein **tar.gz‑Archiv** der AppData  
- Startet den Container nach dem Backup automatisch neu  
- Löscht **Backups älter als 30 Tage**  
- Schreibt alle Schritte und Fehler in eine **Logdatei**  

---

## ⚙️ Voraussetzungen

- Bash‑Umgebung (z. B. Unraid, Linux‑Server, Synology‑NAS)  
- Docker installiert und lauffähig  
- Vaultwarden‑Container mit bekanntem Container‑Namen  
- Schreibrechte auf das Backup‑Verzeichnis

---

## 🧩 Scriptinhalt

```bash
#!/bin/bash
# =========================================================
# Vaultwarden Backup Script (für Unraid)
# Autor: Stefan 😉
# Beschreibung:
#   - Stoppt den Vaultwarden-Container
#   - Erstellt ein tar.gz-Backup der AppData
#   - Startet den Container wieder
#   - Löscht Backups älter als 30 Tage
# =========================================================

set -euo pipefail  # Script bricht bei Fehlern sauber ab

# === Einstellungen ===
DATE=$(date +%Y-%m-%d_%H-%M-%S)
CONTAINER="vaultwarden"
CONTAINER_DATA_DIR="/mnt/user/appdata/vaultwarden"
BACKUP_DIR="/mnt/user/Backup/vaultwarden"
BACKUP_FILE="${BACKUP_DIR}/vaultwarden-${DATE}.tar.gz"
LOGFILE="${BACKUP_DIR}/backup.log"

# === Vorbereitung ===
mkdir -p "$BACKUP_DIR"

echo "[$(date)] === Vaultwarden Backup gestartet ===" | tee -a "$LOGFILE"

# === Container stoppen (nur wenn er läuft) ===
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "[$(date)] Stoppe Container: $CONTAINER" | tee -a "$LOGFILE"
  docker stop "$CONTAINER" >> "$LOGFILE" 2>&1
else
  echo "[$(date)] Container '$CONTAINER' läuft nicht – überspringe Stop." | tee -a "$LOGFILE"
fi

# === Backup erstellen ===
echo "[$(date)] Erstelle Backup unter: $BACKUP_FILE" | tee -a "$LOGFILE"
tar -czf "$BACKUP_FILE" -C "$CONTAINER_DATA_DIR" --transform='s|^\./||' . >> "$LOGFILE" 2>&1

# === Container wieder starten ===
echo "[$(date)] Starte Container: $CONTAINER" | tee -a "$LOGFILE"
docker start "$CONTAINER" >> "$LOGFILE" 2>&1

# === Alte Backups löschen (älter als 30 Tage) ===
echo "[$(date)] Lösche Backups älter als 30 Tage ..." | tee -a "$LOGFILE"
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +30 -exec rm -v {} \; >> "$LOGFILE" 2>&1

echo "[$(date)] === Backup erfolgreich abgeschlossen ===" | tee -a "$LOGFILE"
exit 0
```

---

## 📄 Dateistruktur

| Variable | Beschreibung |
|-----------|---------------|
| `CONTAINER` | Name deines Vaultwarden‑Containers |
| `CONTAINER_DATA_DIR` | Pfad zum Vaultwarden‑AppData‑Verzeichnis |
| `BACKUP_DIR` | Zielverzeichnis für Backups |
| `BACKUP_FILE` | Automatisch generierter Backup‑Dateiname mit Zeitstempel |
| `LOGFILE` | Pfad zur Logdatei |

---

## 🕐 Automatisierung mit Cron

Damit das Script regelmäßig läuft (z. B. täglich um 2 Uhr), Cronjob hinzufügen:

```bash
0 2 * * * /pfad/zu/vaultwarden-backup.sh >> /mnt/user/Backup/vaultwarden/cron.log 2>&1
```

---

## 🧪 Wiederherstellung (Restore)

Zum Wiederherstellen einfach entpacken:

```bash
tar -xzf vaultwarden-YYYY-MM-DD_HH-MM-SS.tar.gz -C /mnt/user/appdata/vaultwarden
```

Danach sicherstellen, dass die Dateiberechtigungen korrekt sind und der Container wieder gestartet werden kann:

```bash
docker start vaultwarden
```

---

## 💡 Tipps

- **Testlauf:** Führe das Script manuell aus, bevor du es in Cron einträgst.  
- **Platz sparen:** Optional alte Logs rotieren oder komprimieren.  
- **Monitoring:** Du kannst Benachrichtigungen hinzufügen (z. B. per Mail oder Discord Webhook).

---
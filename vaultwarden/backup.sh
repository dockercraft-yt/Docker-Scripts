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
#tar -czf "$BACKUP_FILE" -C "$CONTAINER_DATA_DIR" . >> "$LOGFILE" 2>&1

# === Container wieder starten ===
echo "[$(date)] Starte Container: $CONTAINER" | tee -a "$LOGFILE"
docker start "$CONTAINER" >> "$LOGFILE" 2>&1

# === Alte Backups löschen (älter als 30 Tage) ===
echo "[$(date)] Lösche Backups älter als 30 Tage ..." | tee -a "$LOGFILE"
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +30 -exec rm -v {} \; >> "$LOGFILE" 2>&1

echo "[$(date)] === Backup erfolgreich abgeschlossen ===" | tee -a "$LOGFILE"
exit 0

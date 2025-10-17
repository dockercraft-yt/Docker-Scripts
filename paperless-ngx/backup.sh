#!/bin/bash

# === Laufzeit-Variablen ===
varRunTime=$(date +%Y%m%d_%H%M%S)
varDaysOlder=7
LOG_DIR="/mnt/user/Backup/paperless/logs"
LOG_FILE="${LOG_DIR}/paperless-backup_${varRunTime}.log"

# === Environment fix für Cron ===
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANG="C"

# === Verzeichnisse ===
BACKUP_DIR="/mnt/user/Backup/paperless"
CONTAINER="paperless-ngx"

# === Logging-Verzeichnis sicherstellen ===
mkdir -p "$LOG_DIR"

{
echo "+++++++++ $(date +%Y%m%d_%H%M%S) - paperless Backup-Script gestartet +++++++++"
echo

echo "+++++++++ $(date +%Y%m%d_%H%M%S) - Lösche Backups älter als ${varDaysOlder} Tage +++++++++"
find "$BACKUP_DIR" -type f -name '*.zip' -mtime +$varDaysOlder -print
find "$BACKUP_DIR" -type f -name '*.zip' -mtime +$varDaysOlder -exec rm -v {} \;
echo

echo "+++++++++ $(date +%Y%m%d_%H%M%S) - Lösche Logs älter als ${varDaysOlder} Tage +++++++++"
find "$LOG_DIR" -type f -name '*.log' -mtime +$varDaysOlder -print
find "$LOG_DIR" -type f -name '*.log' -mtime +$varDaysOlder -exec rm -v {} \;
echo

echo "+++++ $(date +%Y%m%d_%H%M%S) - paperless Export gestartet +++++"
docker exec -t "$CONTAINER" document_exporter ../export \
  --delete --compare-checksums --zip --zip-name ../backup/paperless-backup_${varRunTime}
echo

echo "+++++ $(date +%Y%m%d_%H%M%S) - paperless Export beendet +++++"
echo "+++++++++ $(date +%Y%m%d_%H%M%S) - paperless Backup-Script beendet +++++++++"
echo
} >> "$LOG_FILE" 2>&1

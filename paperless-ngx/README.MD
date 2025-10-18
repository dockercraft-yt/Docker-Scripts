# 📄 Paperless-NGX Backup Script (Unraid)

## Übersicht

Dieses Script erstellt ein automatisiertes Backup des **Paperless-NGX Containers** auf einem **Unraid-System**.  
Es exportiert die Dokumente über den integrierten `document_exporter`, komprimiert sie als `.zip` und löscht alte Backups sowie Log-Dateien automatisch.

---
## Inhaltsverzeichnis
- [📄 Paperless-NGX Backup Script (Unraid)](#-paperless-ngx-backup-script-unraid)
  - [Übersicht](#übersicht)
  - [Inhaltsverzeichnis](#inhaltsverzeichnis)
  - [Funktionsweise](#funktionsweise)
  - [Voraussetzungen](#voraussetzungen)
  - [Script-Inhalt](#script-inhalt)
  - [Installation auf Unraid](#installation-auf-unraid)
  - [Automatische Ausführung](#automatische-ausführung)
    - [Variante 1: User Scripts Plugin](#variante-1-user-scripts-plugin)
    - [Variante 2: Cronjob](#variante-2-cronjob)
  - [Logs \& Fehleranalyse](#logs--fehleranalyse)
  - [Beispiel Docker Compose Konfiguration](#beispiel-docker-compose-konfiguration)
  - [Bekannte Probleme \& Lösungen](#bekannte-probleme--lösungen)
  - [Version \& Autor](#version--autor)
---

## Funktionsweise

1. Alte Backups und Logs werden gelöscht (älter als `varDaysOlder` Tage)
2. Ein neues Backup wird über `docker exec` im Container Paperless-NGX erstellt
3. Das Backup wird im definierten Backup-Verzeichnis gespeichert
4. Alle Aktionen werden in eine Log-Datei geschrieben

---

## Voraussetzungen

- Ein laufender **Paperless-NGX Docker-Container**
- Schreibrechte im Backup-Verzeichnis `/mnt/user/Backup/paperless`
- Das Script wird als **root oder admin** ausgeführt
- Das Verzeichnis für Logs existiert (wird automatisch angelegt)

---

## Script-Inhalt

```bash
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
docker exec -t "$CONTAINER" document_exporter ../export --delete --compare-checksums --zip --zip-name ../backup/paperless-backup_${varRunTime}
echo

echo "+++++ $(date +%Y%m%d_%H%M%S) - paperless Export beendet +++++"
echo "+++++++++ $(date +%Y%m%d_%H%M%S) - paperless Backup-Script beendet +++++++++"
echo
} >> "$LOG_FILE" 2>&1
```

---

## Installation auf Unraid

1. Erstelle das Script unter:
   ```bash
   /boot/config/scripts/paperless_backup.sh
   ```

2. Vergib Ausführungsrechte:
   ```bash
   chmod +x /boot/config/scripts/paperless_backup.sh
   ```

3. Erstelle bei Bedarf den Backup-Ordner:
   ```bash
   mkdir -p /mnt/user/Backup/paperless/logs
   ```

---

## Automatische Ausführung

### Variante 1: User Scripts Plugin
1. Öffne das **User Scripts Plugin** im Unraid Webinterface  
2. Neues Script anlegen → Scriptinhalt einfügen  
3. Zeitplan festlegen (z. B. täglich um 2 Uhr)  
4. Option „Run in background“ aktivieren

### Variante 2: Cronjob
Alternativ über die Konsole:
```bash
0 2 * * * /boot/config/scripts/paperless_backup.sh
```

---

## Logs & Fehleranalyse

- Logs liegen unter:
  ```bash
  /mnt/user/Backup/paperless/logs/
  ```

- Letzte 20 Zeilen ansehen:
  ```bash
  tail -n 20 /mnt/user/Backup/paperless/logs/paperless-backup_*.log
  ```

- Wenn das Script per Cron läuft, beachte:
  - `PATH` und `LANG` werden im Script gesetzt, damit `find`, `rm`, `docker` etc. funktionieren.
  - Alle Fehler werden ebenfalls in die Log-Datei umgeleitet.

---

## Beispiel Docker Compose Konfiguration

> ⚠️ **WICHTIG:** Unter `volumes:` muss ein **Backup-Verzeichnis** gemountet werden!  
> Ohne dieses Volume kann der `document_exporter` die Backups nicht im Host-System speichern.

```yaml
services:
  paperless-ngx:
    container_name: paperless-ngx
    environment:
      - TZ=Europe/Berlin
      - PAPERLESS_REDIS=redis://default:redis@192.168.178.2:6379
      - PAPERLESS_OCR_LANGUAGE=deu
      - PAPERLESS_OCR_LANGUAGES=deu
      - PAPERLESS_FILENAME_FORMAT={{ created_year }}/{{ created_month }}/{{ added_year }}{{ added_month }}{{ added_day }}-{{ title }}
      - PAPERLESS_TIME_ZONE=Europe/Berlin
      - PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE=true
      - PAPERLESS_CONSUMER_ASN_BARCODE_PREFIX=ASN
      - PAPERLESS_CONSUMER_ENABLE_BARCODES=true
      - PAPERLESS_CONSUMER_BARCODE_SCANNER=ZXING
      - PAPERLESS_CONSUMER_BARCODE_STRING=PATCHT
      - PAPERLESS_ENABLE_HTTP_REMOTE_USER=true
      - PAPERLESS_IGNORE_DATES=
      - PAPERLESS_CONSUMER_POLLING=120
      - PAPERLESS_SECRET_KEY=KEY
      - USERMAP_UID=99
      - USERMAP_GID=100
    ports:
      - 27030:8000/tcp
    volumes:
      - /mnt/user/appdata/paperless-ngx/data:/usr/src/paperless/data
      - /mnt/user/paperless/media/:/usr/src/paperless/media
      - /mnt/user/paperless/consume/:/usr/src/paperless/consume
      - /mnt/user/paperless/export/:/usr/src/paperless/export
      - /mnt/user/Backup/paperless:/usr/src/paperless/backup   # <- Backup Volume ist zwingend erforderlich!
      - /mnt/user/paperless/custom_scripts:/custom-cont-init.d:ro
      - /mnt/user/paperless/consume_script:/usr/src/paperless/scripts
    image: ghcr.io/paperless-ngx/paperless-ngx
```

---

## Bekannte Probleme & Lösungen

| Problem | Ursache | Lösung |
|----------|----------|--------|
| Alte Backups werden nicht gelöscht | `-execdir` funktioniert unter Cron nicht zuverlässig | Im Script wurde `-exec` verwendet |
| `docker exec` schlägt fehl | Containername falsch | Namen in `CONTAINER=` prüfen |
| Kein Logfile wird erstellt | Pfad fehlt oder keine Rechte | `mkdir -p /mnt/user/Backup/paperless/logs` ausführen |
| Script läuft manuell, aber nicht automatisch | Cron-Umgebung unvollständig | `PATH` im Script wie oben gesetzt halten |
| Backups leer oder nicht sichtbar | Kein Backup-Verzeichnis in Docker Compose | Volume `/mnt/user/Backup/paperless:/usr/src/paperless/backup` hinzufügen |

---

## Version & Autor

- **Version:** 1.2 (Unraid-optimiert, Oktober 2025)  
- **Autor:** Stefan  
- **Plattform:** Unraid  
- **Container:** paperless-ngx  

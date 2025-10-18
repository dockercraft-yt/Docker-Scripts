# 🐳 Docker Stack Backup – Dokumentation

**Version:** 1.8  
**Stand:** 18.10.2025  
**Autor:** Dockercraft  

---

## 📋 Übersicht

Dieses Skript dient zur **automatisierten Sicherung von Docker Compose Stacks**, inklusive optionaler Sicherung der persistenten Daten.  
Es ist für den wöchentlichen Betrieb über `cron` ausgelegt und bietet robuste Fehlerbehandlung, Logging und konfigurierbares Verhalten.

---

### Inhaltsverzeichnis
- [🐳 Docker Stack Backup – Dokumentation](#-docker-stack-backup--dokumentation)
  - [📋 Übersicht](#-übersicht)
    - [Inhaltsverzeichnis](#inhaltsverzeichnis)
  - [⚙️ Aufbau](#️-aufbau)
    - [1. Hauptskript](#1-hauptskript)
    - [2. Konfigurationsdatei](#2-konfigurationsdatei)
  - [🗓️ Verwendung im Cron](#️-verwendung-im-cron)
    - [Beispiel Cronjob (wöchentliche Sicherung)](#beispiel-cronjob-wöchentliche-sicherung)
  - [🔍 Funktionsweise](#-funktionsweise)
  - [🧱 Verhalten je nach Stack-Zustand](#-verhalten-je-nach-stack-zustand)
  - [📦 Backup-Struktur](#-backup-struktur)
  - [🧹 Logrotation \& Aufbewahrung](#-logrotation--aufbewahrung)
  - [🧪 Testlauf](#-testlauf)
  - [🧰 Hinweise](#-hinweise)
  - [✅ Beispiel: Manuelles Restore (nur zur Referenz)](#-beispiel-manuelles-restore-nur-zur-referenz)
  - [🧾 Änderungsverlauf](#-änderungsverlauf)


## ⚙️ Aufbau

### 1. Hauptskript

Pfad:  
`/opt/scripts/backup.sh`

Dieses Skript:
- sichert alle Stacks unter `/opt/stacks/[STACKNAME]/`
- erstellt komprimierte Backups (`.tar.gz`) im definierten Backup-Verzeichnis
- optional: sichert persistente Daten (alle Unterordner)
- führt ein Logging mit Datum und Rotation durch
- startet nur Container neu, die vor dem Backup aktiv waren

### 2. Konfigurationsdatei

Pfad:  
`/opt/scripts/backup.conf`

Beispielinhalt:

```bash
#=============================================================================
#
# Docker Stack Backup Configuration
# #=============================================================================

# === Pfade ===
STACKS_DIR="/opt/stacks"
BACKUP_DIR="/opt/docker_backups"
LOG_DIR="/var/log/docker_backups"

# === Verhalten ===
INCLUDE_DATA=true           # true/false → Soll der Data-Ordner gesichert werden?
RETENTION_DAYS=30           # Alte Backups löschen nach X Tagen
LOG_RETENTION_DAYS=14       # Alte Logs löschen nach X Tagen

# === Kritische Container (nicht stoppen / keine Daten sichern) ===
SKIP_STOP=("traefik" "portainer" "watchtower")
```

---

## 🗓️ Verwendung im Cron

### Beispiel Cronjob (wöchentliche Sicherung)

```bash
0 3 * * 0 /opt/scripts/backup.sh
```
➡ Läuft **sonntags um 3 Uhr**  
➡ Erstellt ein Logfile: `/var/log/docker_backups/backup_YYYY-MM-DD.log`  
➡ Alte Logs & Backups werden automatisch gelöscht  

---

## 🔍 Funktionsweise

| Schritt | Beschreibung |
|----------|---------------|
| 1️⃣ | Erkennung aller Stacks unter `/opt/stacks` |
| 2️⃣ | Sicherung der `compose.yaml` und `.env` Dateien |
| 3️⃣ | Optional: Stoppen des Stacks und Backup der Unterordner |
| 4️⃣ | Komprimierung der Sicherung zu `.tar.gz` |
| 5️⃣ | Neustart nur, wenn Stack vorher aktiv war |
| 6️⃣ | Aufräumen alter Backups und Logs |

---

## 🧱 Verhalten je nach Stack-Zustand

| Stack-Zustand | Verhalten beim Backup |
|----------------|-----------------------|
| **Läuft** | Stack wird gestoppt, gesichert und danach wieder gestartet |
| **Gestoppt** | Stack bleibt gestoppt, es erfolgt nur Dateisicherung |
| **In Skip-Liste** | Keine Stop-/Start-Aktion, nur Compose-Dateien werden gesichert |

---

## 📦 Backup-Struktur

```
/opt/docker_backups/
├── nextcloud_2025-10-13_03-00-00.tar.gz
├── traefik_2025-10-13_03-00-00.tar.gz
└── ...
```

Im Archiv enthalten:
```
compose.yaml
.env
[STACKNAME]_data.tar.gz (falls Daten gesichert)
```

---

## 🧹 Logrotation & Aufbewahrung

- Logs älter als `LOG_RETENTION_DAYS` Tage werden automatisch gelöscht  
- Backups älter als `RETENTION_DAYS` Tage werden automatisch entfernt  

---

## 🧪 Testlauf

Vor der ersten Verwendung sollte das Skript **manuell getestet** werden:

```bash
sudo bash /opt/scripts/docker_backup.sh
```

Die Logausgabe wird dabei in die Konsole und ins Logfile geschrieben.

---

## 🧰 Hinweise

- Das Skript benötigt `docker compose` (nicht `docker-compose`)
- Achte auf ausreichenden Speicherplatz im Backup-Verzeichnis
- Überprüfe regelmäßig die Logdateien auf Fehler oder Warnungen
- Restore erfolgt **manuell** über Entpacken und Starten des Stacks

---

## ✅ Beispiel: Manuelles Restore (nur zur Referenz)

```bash
tar -xzf /opt/docker_backups/nextcloud_2025-10-13_03-00-00.tar.gz -C /opt/stacks/
cd /opt/stacks/nextcloud
docker compose up -d
```

---

## 🧾 Änderungsverlauf

| Version | Datum | Änderung |
|----------|--------|-----------|
| 1.0 | Initial | Grundlegende Backup-Funktion |
| 1.5 | Logging & Config ausgelagert | Einführung der Config-Datei |
| 1.7 | Kritische Container | Ausschluss von Containergruppen |
| 1.8 | Smart Restart | Containerzustand wird berücksichtigt |

---
# Docker Volume Cleanup Script

Dieses Skript entfernt automatisch alle ungenutzten („dangling") Docker
Volumes und kann ideal als Cronjob eingesetzt werden, um das System
sauber zu halten.

## Zweck

Mit der Zeit sammeln sich Docker Volumes an, die nicht mehr genutzt
werden. Dieses Skript findet solche Volumes und löscht sie automatisch.
Dadurch wird Speicherplatz freigegeben und die Übersichtlichkeit
verbessert.

## Funktionsweise

Das Skript: 1. Ermittelt alle ungenutzten Docker Volumes
(`docker volume ls -qf dangling=true`) 2. Prüft, ob Volumes zum Löschen
vorhanden sind 3. Löscht diese Volumes 4. Schreibt alle Aktionen in eine
Logdatei unter `/var/log/docker-volume-cleanup.log`

## Skript

``` bash
#!/bin/bash

# Entfernt alle ungenutzten Docker Volumes (dangling)
# und schreibt ein Log, damit du nachvollziehen kannst, was gelöscht wurde.

LOGFILE="/var/log/docker-volume-cleanup.log"

echo "===== $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOGFILE"

UNUSED_VOLUMES=$(docker volume ls -qf dangling=true)

if [ -z "$UNUSED_VOLUMES" ]; then
    echo "Keine ungenutzten Volumes gefunden." >> "$LOGFILE"
    exit 0
fi

echo "Folgende ungenutzte Volumes werden gelöscht:" >> "$LOGFILE"
echo "$UNUSED_VOLUMES" >> "$LOGFILE"

docker volume rm $UNUSED_VOLUMES >> "$LOGFILE" 2>&1

echo "Cleanup abgeschlossen." >> "$LOGFILE"
echo "" >> "$LOGFILE"
```

## Installation

1.  Datei speichern, z. B.:

```bash
/root/scripts/docker-volume-cleanup.sh
```

2.  Ausführbar machen:

``` bash
chmod +x /root/scripts/docker-volume-cleanup.sh
```

3.  Optional: Logfile anlegen (falls nicht automatisch):

``` bash
touch /var/log/docker-volume-cleanup.log
```

## Cronjob einrichten

Beispiel: Täglich um 03:00 Uhr ausführen.

``` bash
crontab -e
```

Eintrag:

    0 3 * * * /root/scripts/docker-volume-cleanup.sh

## Hinweise

-   Das Skript löscht **alle** ungenutzten Docker Volumes. Stelle
    sicher, dass du keine alten Daten benötigst.
-   Das Logfile hilft dir, nachvollziehen zu können, was entfernt wurde.

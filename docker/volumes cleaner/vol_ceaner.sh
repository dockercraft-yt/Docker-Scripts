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

# Löschen
docker volume rm $UNUSED_VOLUMES >> "$LOGFILE" 2>&1

echo "Cleanup abgeschlossen." >> "$LOGFILE"
echo "" >> "$LOGFILE"

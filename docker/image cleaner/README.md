---
title: "Docker Image Cleanup Script"
author: "Stefan"
date: "2025-10-19"
version: "1.0"
description: "Dokumentation zum Bash-Skript zur automatischen Bereinigung ungenutzter Docker-Images."
---

# 🧾 Docker Image Cleanup Script

### Inhaltsverzeichnis
- [🧾 Docker Image Cleanup Script](#-docker-image-cleanup-script)
    - [Inhaltsverzeichnis](#inhaltsverzeichnis)
  - [Dateiname](#dateiname)
  - [Zweck](#zweck)
  - [Funktionsweise](#funktionsweise)
  - [Voraussetzungen](#voraussetzungen)
  - [Verwendung](#verwendung)
  - [Beispielausgabe](#beispielausgabe)
  - [Hinweise](#hinweise)
  - [Optionale Erweiterungen](#optionale-erweiterungen)



## Dateiname
`cleaner.sh`

---

## Zweck
Dieses Skript dient dazu, ungenutzte Docker-Images zu entfernen, um Speicherplatz auf dem System freizugeben.  
Es zeigt vor und nach der Bereinigung den belegten Speicherplatz durch Docker-Komponenten an.

---

## Funktionsweise

Das Skript führt folgende Schritte aus:

1. **Anzeige des aktuellen Docker-Speicherverbrauchs**
   ```bash
   docker system df
   ```
   → Zeigt Speicherverbrauch von Images, Containern, Volumes und Caches.

2. **Löschen ungenutzter Images**
   ```bash
   docker image prune -a --force
   ```
   → Entfernt **alle Images**, die aktuell von keinem Container verwendet werden.  
   Das `-a` steht für „all“, also auch Images, die nicht als „dangling“ markiert sind.  
   Das `--force` unterdrückt die Bestätigungsabfrage.

3. **Anzeige des neuen Speicherverbrauchs**
   ```bash
   docker system df
   ```
   → Zeigt den neuen Speicherverbrauch nach der Bereinigung an.

---

## Voraussetzungen
- Docker muss auf dem System installiert und im Pfad verfügbar sein.  
- Das Skript benötigt **root- oder sudo-Rechte**, falls Docker für den aktuellen Benutzer nicht direkt ausführbar ist.

---

## Verwendung
1. Skript speichern, z. B. unter `/usr/local/bin/cleaner.sh`
2. Ausführbar machen:
   ```bash
   chmod +x /usr/local/bin/cleaner.sh
   ```
3. Skript ausführen:
   ```bash
   ./cleaner.sh
   ```
   oder mit Root-Rechten:
   ```bash
   sudo ./cleaner.sh
   ```

---

## Beispielausgabe
```
📦 Speicherverbrauch vor der Bereinigung:
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        4         10GB      8GB (80%)
Containers      4         4         200MB     0B (0%)
Local Volumes   2         2         50MB      0B (0%)
Build Cache     0         0         0B        0B

🚀 Lösche ungenutzte Docker Images...

Deleted Images:
deleted: sha256:123abc...
deleted: sha256:456def...

📦 Speicherverbrauch nach der Bereinigung:
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          4         4         2GB       0B (0%)
...
```

---

## Hinweise
- Das Skript entfernt **keine laufenden oder gestoppten Container**.  
- Es löscht **nur Images**, die nicht mehr mit einem Container verknüpft sind.  
- Regelmäßige Ausführung kann helfen, Speicherplatz auf Build- oder Testsystemen freizuhalten.  
- In produktiven Umgebungen sollte geprüft werden, ob Images evtl. noch benötigt werden.

---

## Optionale Erweiterungen
- Automatische Protokollierung der gelöschten Images in einer Log-Datei  
- Optionale Bestätigung vor dem Löschen  
- Integration in `cron` oder `systemd`-Timer für regelmäßige Bereinigung

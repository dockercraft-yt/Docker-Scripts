[Deutsch](./README.md) | [English](./README_EN.md)

# 🐳 Docker-Scripts

Dieses Repository enthält eine Sammlung von nützlichen Shell-Skripten rund um Docker-Container, deren Verwaltung und Backup-Prozesse.  
Alle Skripte wurden mit dem Ziel entwickelt, wiederkehrende Aufgaben zu automatisieren und die Administration von Containern zu vereinfachen.

---

## 📂 Verzeichnisstruktur

```
Docker-Scripts/
│
├── Docker/
│   ├── Docker Container Backup/      # Backup von Container-Daten und Volumes
│   ├── Docker Container Restore/     # Wiederherstellen von Backups
│   ├── Docker Installer/             # Installiert Docker, Docker Compose und einen User
│   ├── Docker Volume Cleaner/        # Entfernt ungenutzte Docker-Volumes
│   └── Docker Image Cleaner/         # Entfernt ungenutzte Docker-Images
│
├── paperless-ngx/             # Backup-Skript für Paperless-ngx
└── vaultwarden/               # Backup-Skript für Vaultwarden

```

---

## ⚙️ Inhalt & Funktionen

### 🧱 Docker
Enthält generische Skripte für die Docker-Verwaltung:

| Ordner | Beschreibung |
|--------|---------------|
| **Docker Container Backup** | Erstellt automatisierte Backups von Container-Daten, inklusive Volumes. |
| **Docker Container Restore** | Stellt Backups aus dem Backup-Verzeichnis wieder her. |
| **Docker Image Cleaner** | Bereinigt ungenutzte Images, um Speicherplatz freizugeben. |
| **Docker Installer** | Installiert Docker, Docker Compose, erstellt einen User "docker" mit der Gruppe "docker"|
| **Docker Volume Cleaner**| Entfernt nicht mehr benötigte Docker Volumes die unnötig Speicherplatz verbrauchen|

Jedes Unterverzeichnis enthält eine eigene `README.md` mit Details zur Verwendung.

---

### 📦 Paperless-NGX
Skript zum automatisierten Backup der **Paperless-NGX**-Docker-Instanz (Dokumentenmanagementsystem).  
Beinhaltet die Sicherung von Datenbank und Dokumentenverzeichnis.

📄 [Mehr Infos in `paperless-ngx/README.md`](./paperless-ngx/README.md)

---

### 🔐 Vaultwarden
Skript für **Vaultwarden** (selbstgehosteter Passwortmanager).  
Führt vollständige Sicherungen von Konfigurations- und Datenverzeichnissen durch.

📄 [Mehr Infos in `vaultwarden/README.md`](./vaultwarden/README.md)

---

## 🧰 Voraussetzungen

- Docker (mind. Version 20.x)
- Bash-Shell (Linux oder WSL unter Windows)
- Schreibrechte auf das Ziel-Backupverzeichnis

---

## 🚀 Verwendung

Klonen des Repositories:

```bash
git clone https://github.com/dockercraft-yt/Docker-Scripts.git
cd Docker-Scripts
```

Beispiel: Container-Backup starten

```bash
cd Docker/Container\ Backup
bash backup.sh
```

Backup wiederherstellen:

```bash
cd Docker/Container\ Restore
bash restore.sh
```

---

## 🧾 Lizenz

Dieses Projekt steht unter der **MIT-Lizenz**.  
Details findest du in der Datei [`LICENSE`](./LICENSE).

---

## 📢 Mitwirken

Pull Requests sind willkommen!  
Wenn du Ideen oder Verbesserungen hast, öffne gerne ein Issue oder reiche direkt einen PR ein.

---

© 2025 [DockerCraft](https://github.com/dockercraft-yt)

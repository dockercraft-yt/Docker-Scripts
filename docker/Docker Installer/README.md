# Docker Installation Script for Debian

Dieses Repository enthält ein Bash-Skript, das auf einem aktuellen **Debian-System**
die vollständige Installation von **Docker**, **Docker Compose (Plugin)** und einem
dedizierten System-User (`docker`) durchführt.

Das Skript wurde so entwickelt, dass es **einmalig** ausgeführt wird und sich bewusst
weigert, bestehende Nutzer oder Gruppen zu überschreiben. Zusätzlich schreibt es alle
Abläufe in ein Logfile.

---

## 🎯 Zweck

Das Skript automatisiert folgende Aufgaben:

1. Installation der offiziellen Docker Engine über das Docker Repository  
2. Installation des Docker Compose Plugins  
3. Anlegen eines dedizierten System-Users  
   - Name: `docker`  
   - UID: **1001**  
   - GID: **1001**  
   - kein Passwort  
   - kein SSH-Login (`/usr/sbin/nologin`)  
4. Logging aller Aktionen nach `/var/log/docker-install.log`

Der User wird ausschließlich für **Berechtigungen, Eigentümerstrukturen** und die
Verwaltung von Dateien genutzt – **nicht** für interaktive Logins.

---

## ⚙️ Funktionsweise

Das Skript führt folgende Schritte durch:

1. Prüfen, ob Root-Rechte vorhanden sind  
2. Prüfen, ob UID/GID 1001 verfügbar sind  
3. Erstellen der Gruppe `docker`  
4. Erstellen des Benutzers `docker`  
5. Entfernen des Passworts + Deaktivierung von Login/Shell  
6. Einrichten des Docker-Repositories  
7. Installation aller Docker-Komponenten  
8. Hinzufügen des Users zur `docker`-Gruppe  
9. Schreiben aller Ausgaben in ein Logfile

Jeder Schritt wird mit Zeitstempel ins Log geschrieben.

---

## 📦 Voraussetzungen

- Debian 12 oder neuer  
- Root-Zugriff  
- Internetverbindung  
- UID 1001 und GID 1001 müssen frei sein  
- Gruppe `docker` darf noch nicht existieren  
- Benutzer `docker` darf noch nicht existieren  

---

## ▶️ Verwendung

1. Skript herunterladen und ausführbar machen:

```bash
chmod +x docker-install.sh
```

1. Skript ausführen:

```bash
sudo ./docker-install.sh
```

3. Nach der Installation befindet sich das Log hier:

```bash
/var/log/docker-install.log
```

---

## 📝 Beispielausgabe (Auszug)

```
2025-01-01 12:34:56 | === START: Docker Installation ===
2025-01-01 12:34:56 | Gruppe 'docker' mit GID 1001 erstellt.
2025-01-01 12:34:56 | User 'docker' erstellt (UID 1001, ohne Passwort, kein SSH-Login).
2025-01-01 12:34:57 | Docker Repository hinzugefügt.
2025-01-01 12:35:10 | Docker Engine + Compose Plugin installiert.
2025-01-01 12:35:10 | === INSTALLATION ABGESCHLOSSEN ===
```

---

## 🔍 Hinweise

- Dieses Skript sollte **nur einmalig** ausgeführt werden.  
- Wenn UID/GID 1001 bereits vergeben sind, bricht das Skript bewusst ab.  
- Der Benutzer `docker` ist nicht für interaktive Logins gedacht.  
- Das Skript verwendet `set -e`, um bei Fehlern sofort zu stoppen.  

---

## 🚀 Optionale Erweiterungen

Falls du das Skript erweitern möchtest, bieten sich folgende Features an:

- Prüfung, ob Docker bereits installiert ist  
- Automatische Absicherung von Docker Daemon Einstellungen  
- Aktivieren eines alternativen Logdrivers  
- Erstellung eines Systemd-Dienstes für eigene Docker-Workloads  
- Option zur Konfiguration eines privaten Registrys
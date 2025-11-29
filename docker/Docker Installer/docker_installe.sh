#!/bin/bash
set -e

LOGFILE="/var/log/docker-install.log"

# --- Setup logging ---
touch "$LOGFILE"
chmod 600 "$LOGFILE"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOGFILE"
}

log "=== START: Docker Installation ==="

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
    log "FEHLER: Skript muss als root ausgeführt werden!"
    exit 1
fi

# --- UID/GID prüfen ---
if getent passwd 1001 >/dev/null; then
    log "FEHLER: UID 1001 ist bereits vergeben!"
    exit 1
fi

if getent group 1001 >/dev/null; then
    log "FEHLER: GID 1001 ist bereits vergeben!"
    exit 1
fi

# --- Gruppe erstellen ---
if getent group docker >/dev/null; then
    log "FEHLER: Gruppe 'docker' existiert bereits!"
    exit 1
fi

groupadd -g 1001 docker
log "Gruppe 'docker' mit GID 1001 erstellt."

# --- User erstellen (ohne Passwort, kein Login) ---
if id docker >/dev/null 2>&1; then
    log "FEHLER: User 'docker' existiert bereits!"
    exit 1
fi

useradd -m -u 1001 -g 1001 -s /usr/sbin/nologin docker
passwd -d docker >/dev/null 2>&1 || true
log "User 'docker' erstellt (UID 1001, ohne Passwort, kein SSH-Login)."

# --- Docker Voraussetzungen ---
log "Installiere benötigte Pakete..."
apt update | tee -a "$LOGFILE"
apt install -y ca-certificates curl gnupg lsb-release | tee -a "$LOGFILE"

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

log "Docker Repository hinzugefügt."

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt update | tee -a "$LOGFILE"

# --- Docker + Docker Compose installieren ---
log "Installiere Docker Engine + Compose Plugin..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    | tee -a "$LOGFILE"

# --- Berechtigung vergeben ---
usermod -aG docker docker
log "User 'docker' zu Gruppe 'docker' hinzugefügt."

log "=== INSTALLATION ABGESCHLOSSEN ==="
log "Docker + Compose wurden installiert."
log "User 'docker' ist aktiv (nur für UID/GID, kein SSH)."

echo
echo "Installation fertig. Logfile: $LOGFILE"

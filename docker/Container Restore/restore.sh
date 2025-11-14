#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Docker Stack Restore Script (v1.0)
# =============================================================================
# Description:
#   Safely restores a backed-up Docker stack from /opt/docker_backups/
#   Matching the structure used by docker_backup.sh
# Author: Stefan
# =============================================================================

# === CONFIGURATION LOADING ===
CONFIG_FILE="$(dirname "$0")/docker_backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

# === LOGGING ===
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# === PRECHECKS ===
if [[ ! -d "$BACKUP_DIR" ]]; then
    log "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

if [[ ! -d "$STACKS_DIR" ]]; then
    log "❌ Stacks directory not found: $STACKS_DIR"
    exit 1
fi

# === MAIN ===
log "=============================================================="
log "🧰 Docker Stack Restore Tool"
log "=============================================================="

# --- Step 1: Backup auswählen ---
log "📦 Available backups in: $BACKUP_DIR"
mapfile -t BACKUPS < <(find "$BACKUP_DIR" -type f -name "*.tar.gz" | sort -r)

if (( ${#BACKUPS[@]} == 0 )); then
    log "⚠️  No backups found in $BACKUP_DIR"
    exit 1
fi

i=1
for b in "${BACKUPS[@]}"; do
    echo "[$i] $(basename "$b")"
    ((i++))
done

echo
read -rp "Select backup number to restore: " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#BACKUPS[@]} )); then
    log "❌ Invalid selection."
    exit 1
fi

BACKUP_FILE="${BACKUPS[$((selection - 1))]}"
BASENAME=$(basename "$BACKUP_FILE" .tar.gz)
STACK_NAME="${BASENAME%%_*}"
RESTORE_PATH="$STACKS_DIR/$STACK_NAME"

log "🗂️  Selected backup: $BACKUP_FILE"
log "📁 Stack name detected: $STACK_NAME"
log "📍 Target restore path: $RESTORE_PATH"
echo

# --- Step 2: Ziel prüfen ---
if [[ -d "$RESTORE_PATH" ]]; then
    read -rp "⚠️  Target directory already exists. Overwrite existing files? (y/N): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
        log "❌ Restore aborted by user."
        exit 0
    fi
else
    mkdir -p "$RESTORE_PATH"
fi

# --- Step 3: Backup entpacken ---
TMP_DIR=$(mktemp -d)
log "📦 Extracting backup to temporary directory..."
tar -xzf "$BACKUP_FILE" -C "$TMP_DIR"

log "📂 Extracting stack files into $RESTORE_PATH ..."
cp -r "$TMP_DIR"/* "$RESTORE_PATH"/

# --- Step 4: Daten-Archiv entpacken ---
DATA_ARCHIVE=$(find "$RESTORE_PATH" -maxdepth 1 -type f -name "*_data.tar.gz" || true)
if [[ -n "$DATA_ARCHIVE" ]]; then
    read -rp "Restore persistent data as well? (y/N): " restore_data
    if [[ "$restore_data" == "y" || "$restore_data" == "Y" ]]; then
        log "🗃️  Extracting persistent data..."
        tar -xzf "$DATA_ARCHIVE" -C "$RESTORE_PATH"
        rm -f "$DATA_ARCHIVE"
    else
        log "⏭️  Skipping persistent data restore."
    fi
else
    log "ℹ️  No data archive found for this stack."
fi

# --- Step 5: Abschluss ---
rm -rf "$TMP_DIR"

log "✅ Restore complete for stack: $STACK_NAME"
log "--------------------------------------------------------------"
log "Next steps:"
echo "  cd \"$RESTORE_PATH\""
echo "  docker compose up -d"
echo
log "=============================================================="

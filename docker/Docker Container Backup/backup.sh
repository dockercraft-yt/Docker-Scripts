#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Docker Stack Backup Script (v1.8)
# =============================================================================
# Description: Safely backs up all Docker Compose stacks under /opt/stacks/
# Configuration: /opt/scripts/docker_backup.conf
# Author: Stefan
# =============================================================================

# === CONFIGURATION LOADING ===
CONFIG_FILE="$(dirname "$0")/backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Load config
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# === PREPARATION ===
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_TAG=$(date +"%Y-%m-%d")

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/backup_${DATE_TAG}.log"

# === LOGGING SETUP ===
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# === FUNCTIONS ===
in_skip_list() {
    local name="$1"
    for skip in "${SKIP_STOP[@]}"; do
        if [[ "$skip" == "$name" ]]; then
            return 0
        fi
    done
    return 1
}

is_stack_running() {
    local path="$1"
    local count
    count=$(cd "$path" && docker compose ps -q | wc -l)
    (( count > 0 ))
}

stop_stack() {
    local path="$1"
    local name="$2"
    log "⏸️  Stopping containers for stack: $name"
    (cd "$path" && docker compose down) || log "⚠️  Could not stop $name (maybe not running)."
}

start_stack() {
    local path="$1"
    local name="$2"
    log "▶️  Restarting containers for stack: $name"
    (cd "$path" && docker compose up -d) || log "⚠️  Could not start $name back up!"
}

# === MAIN ===
log "=============================================================="
log "🚀 Starting Docker Backup — $TIMESTAMP"
log "Configuration: $CONFIG_FILE"
log "Logs written to: $LOG_FILE"
log "=============================================================="

STACKS=()
for d in "$STACKS_DIR"/*; do
    [ -d "$d" ] && STACKS+=("$(basename "$d")")
done

log "📋 Found ${#STACKS[@]} stacks:"
for s in "${STACKS[@]}"; do
    if in_skip_list "$s"; then
        log "   🚫 $s (skipped from stop/data backup)"
    else
        log "   ✅ $s (full backup)"
    fi
done
log "---------------------------------------------------------------"

for STACK_NAME in "${STACKS[@]}"; do
    STACK_PATH="$STACKS_DIR/$STACK_NAME"
    STACK_BACKUP_DIR="$BACKUP_DIR/${STACK_NAME}_${TIMESTAMP}"

    log "📦 Processing stack: $STACK_NAME"
    mkdir -p "$STACK_BACKUP_DIR"

    # 1️⃣ Compose + env sichern
    find "$STACK_PATH" -maxdepth 1 -type f \( -name "compose.yaml" -o -name "compose.yml" -o -name ".env" \) \
        -exec cp {} "$STACK_BACKUP_DIR"/ \; || true

    # 2️⃣ Daten sichern
    if [[ "$INCLUDE_DATA" == "true" ]]; then
        if in_skip_list "$STACK_NAME"; then
            log "🚫 Skipping stop & data backup for critical stack: $STACK_NAME"
        else
            if is_stack_running "$STACK_PATH"; then
                log "🟢 Stack is running — stopping for backup..."
                was_running=true
                stop_stack "$STACK_PATH" "$STACK_NAME"
            else
                log "⚪ Stack is not running — will not start after backup."
                was_running=false
            fi

            SUBDIRS=($(find "$STACK_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort))
            if (( ${#SUBDIRS[@]} > 0 )); then
                log "🗂️  Found ${#SUBDIRS[@]} directories, backing them up..."
                tar -czf "$STACK_BACKUP_DIR/${STACK_NAME}_data.tar.gz" -C "$STACK_PATH" "${SUBDIRS[@]}"
            else
                log "⚠️  No data directories found for $STACK_NAME — skipping data backup."
            fi

            if [[ "$was_running" == true ]]; then
                start_stack "$STACK_PATH" "$STACK_NAME"
            fi
        fi
    else
        log "ℹ️  Skipping data backup (INCLUDE_DATA=false)"
    fi

    # 3️⃣ Komprimieren
    log "📦 Compressing final archive..."
    tar -czf "${STACK_BACKUP_DIR}.tar.gz" -C "$BACKUP_DIR" "$(basename "$STACK_BACKUP_DIR")"
    rm -rf "$STACK_BACKUP_DIR"

    log "✅ Backup complete: ${STACK_BACKUP_DIR}.tar.gz"
done

# 4️⃣ Alte Backups löschen
log "🧹 Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -name "*.tar.gz" -exec rm -f {} \;

# 5️⃣ Alte Logs löschen
log "🧾 Removing logs older than $LOG_RETENTION_DAYS days..."
find "$LOG_DIR" -type f -mtime +$LOG_RETENTION_DAYS -name "backup_*.log" -exec rm -f {} \;

log "🎉 All backups completed successfully."
log "=============================================================="

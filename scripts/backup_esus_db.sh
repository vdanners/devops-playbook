#!/bin/bash

# ==============================================================================
# Script: backup_esus_db.sh
# Description: Performs a PostgreSQL database backup (e-SUS APS), validates mount points
#              with auto-recovery, cleans up old backups, and sends alerts via Telegram.
# Author: Victor Danner
# ==============================================================================

# Fail fast: Exit immediately if a command exits with a non-zero status
set -euo pipefail

# --- LOGGING FUNCTIONS ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- CONFIGURATION & VARIABLES ---
# Loads credentials from a secure local file (NOT versioned in Git)
CREDENTIALS_FILE="/home/ubuntu/.telegram_env"

if [ -f "$CREDENTIALS_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CREDENTIALS_FILE"
else
    log_warn "Credentials file ($CREDENTIALS_FILE) not found. Telegram alerts are disabled."
    TELEGRAM_TOKEN="UNSET"
    TELEGRAM_CHAT_ID="UNSET"
fi

HOST=$(hostname)
DATE=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="/bkp/esusbackups/$HOST"
DESTINATION="$BACKUP_DIR/$HOST-$DATE.backup"
RETENTION_DAYS=6

# Database Configuration
PG_DUMP_PATH="/opt/e-SUS/database/postgresql-9.6.13-1-linux-x64/bin/pg_dump"
DB_USER="postgres"
DB_PORT=5433
DB_NAME="esus"

# --- FUNCTIONS ---
send_telegram_alert() {
    local message="$1"
    # Skip if token is default (useful for local testing without Telegram)
    if [[ "$TELEGRAM_TOKEN" == "YOUR_TELEGRAM_TOKEN" ]]; then
        log_warn "Telegram token not configured. Skipping alert: $message"
        return
    fi
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID&text=$message" > /dev/null
}

# --- MAIN EXECUTION ---
log_info "Starting backup process for host: $HOST"

# 1. MOUNT VALIDATION AND AUTO-RECOVERY
if ! grep -qs '/bkp' /proc/mounts; then
    log_warn "Mount point /bkp not found in /proc/mounts. Attempting to mount..."
    sudo mount -a || true
    
    sleep 3
    
    # Second check to ensure mount was successful
    if ! grep -qs '/bkp' /proc/mounts; then
        error_msg="⚠️ BACKUP ERROR ($HOST): Directory /bkp is not mounted and 'mount -a' failed."
        log_error "$error_msg"
        send_telegram_alert "$error_msg"
        exit 1
    fi
    log_info "Mount restored successfully."
fi

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# 2. DATABASE DUMP
log_info "Executing pg_dump for database: $DB_NAME..."

# Temporarily disable 'set -e' to handle pg_dump failure gracefully
set +e
$PG_DUMP_PATH -w --host localhost --port $DB_PORT -U "$DB_USER" \
    --format custom --blobs --encoding UTF8 --no-privileges \
    --no-tablespaces --no-unlogged-table-data "$DB_NAME" > "$DESTINATION"
DUMP_STATUS=$?
set -e

# 3. ERROR HANDLING
if [ $DUMP_STATUS -ne 0 ]; then
    error_msg="❌ BACKUP ERROR ($HOST): pg_dump failed. Check database status."
    log_error "$error_msg"
    send_telegram_alert "$error_msg"
    
    # Cleanup corrupted/empty file
    if [ -f "$DESTINATION" ]; then
        rm -f "$DESTINATION"
    fi
    exit 1
fi

# 4. CLEANUP OLD BACKUPS
log_info "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR/" -name "*.backup" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;

log_info "✅ Backup completed successfully on $DATE. File saved at: $DESTINATION"
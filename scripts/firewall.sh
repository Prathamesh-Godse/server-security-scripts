#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

CONFIG_FILE="$BASE_DIR/configs/firewall.conf"
LOG_FILE="$BASE_DIR/secure-server-scripts.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a "$LOG_FILE"
}

log "Starting firewall configuration..."

# Check config file
if [ ! -f "$CONFIG_FILE" ]; then
    log "ERROR: Config file not found!"
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"

# Check UFW
if ! command -v ufw &> /dev/null; then
    log "UFW not installed. Installing..."
    sudo apt update
    sudo apt install -y ufw
fi

log "Resetting firewall"
sudo ufw --force reset

log "Setting default policies"
sudo ufw default "$DEFAULT_INCOMING" incoming
sudo ufw default "$DEFAULT_OUTGOING" outgoing

# Allow ports
IFS=',' read -ra PORTS <<< "$ALLOW"
for port in "${PORTS[@]}"; do
    log "Allowing port $port"
    sudo ufw allow "$port"
done

# Deny ports
IFS=',' read -ra PORTS <<< "$DENY"
for port in "${PORTS[@]}"; do
    log "Denying port $port"
    sudo ufw deny "$port"
done

# Ping rule
if [ "$ALLOW_PING" = "no" ]; then
    log "Disabling ping"
    sudo ufw deny proto icmp
else
    log "Ping allowed"
fi

log "Enabling firewall"
sudo ufw --force enable

log "Firewall configuration complete"

sudo ufw status verbose | tee -a "$LOG_FILE"

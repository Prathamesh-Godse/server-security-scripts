#!/bin/bash

CONFIG_FILE="./configs/firewall.conf"
LOG_FILE="./logs/firewall.log"

log(){
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a $LOG_FILE
}

log "Starting firewall configuration..."

# Check if UFW exists
if ! command -v ufw &> /dev/null
then
    log "UFW not installed. Installing..."
    sudo apt update
    sudo apt install ufw -y
fi

# Load config
source $CONFIG_FILE

log "Resetting firewall rules"
sudo ufw --force reset

log "Setting default policies"
sudo ufw default $DEFAULT_INCOMING incoming
sudo ufw default $DEFAULT_OUTGOING outgoing

# Allow ports
IFS=',' read -ra ALLOW_PORTS <<< "$ALLOW"
for port in "${ALLOW_PORTS[@]}"
do
    log "Allowing port $port"
    sudo ufw allow $port
done

# Deny ports
IFS=',' read -ra DENY_PORTS <<< "$DENY"
for port in "${DENY_PORTS[@]}"
do
    log "Denying port $port"
    sudo ufw deny $port
done

# Ping rule
if [ "$ALLOW_PING" == "no" ]; then
    log "Disabling ping"
    sudo ufw deny proto icmp
else
    log "Ping allowed"
fi

log "Enabling firewall"
sudo ufw --force enable

log "Firewall configuration completed"
sudo ufw status verbose | tee -a $LOG_FILE

#!/bin/bash

STATE_FILE="./state"

# ---- Initial setup ----
SERVICE_SRC="./secure-server-scripts.service"
SERVICE_DEST="/etc/systemd/system/"

if [ ! -f "$SERVICE_DEST" ]; then
    echo "Installing systemd service..."

    sudo cp "$SERVICE_SRC" "$SERVICE_DEST"
    sudo systemctl daemon-reload
    sudo systemctl enable secure-server-scripts.service
fi

# ---- State management ----
STEP=1
[ -f "$STATE_FILE" ] && STEP=$(cat "$STATE_FILE")

case "$STEP" in
    1)
        echo "Running step 1"
        ./scripts/firewall.sh
        echo 2 > "$STATE_FILE"
        reboot
        ;;
esac

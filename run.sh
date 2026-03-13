#!/bin/bash

STATE_FILE="./state"

STEP=1
[ -f "$STATE_FILE" ] && STEP=$(cat "$STATE_FILE")

case "$STEP" in
    1)
        echo "Running step 1"
        ./step1.sh
        echo 2 > "$STATE_FILE"
        reboot
        ;;
    2)
        echo "Running step 2"
        ./step2.sh
        echo 3 > "$STATE_FILE"
        ;;
    3)
        echo "Running step 3"
        ./step3.sh
        rm -f "$STATE_FILE"
        ;;
esac

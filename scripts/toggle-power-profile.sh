#!/usr/bin/env bash
CURRENT=$(powerprofilesctl get)

if [ "$CURRENT" = "performance" ]; then
    powerprofilesctl set balanced
    notify-send -u low -i preferences-system-power -a "Power Profile" "Power Profile" "Switched to: Balanced"
else
    powerprofilesctl set performance
    notify-send -u normal -i preferences-system-power -a "Power Profile" "Power Profile" "Switched to: Performance"
fi

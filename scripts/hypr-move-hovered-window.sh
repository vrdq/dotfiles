#!/bin/bash
# Move window under cursor (or active focused window) to target workspace

target_ws="$1"

if [ -z "$target_ws" ]; then
    exit 0
fi

# Move window using native hyprctl movetoworkspacesilent or movetoworkspace
hyprctl dispatch movetoworkspace "$target_ws" 2>/dev/null || hyprctl dispatch movetoworkspacesilent "$target_ws"

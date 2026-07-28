#!/bin/bash
# Script to toggle showing desktop using Hyprland 0.55+ Lua eval (hl.dispatch)

STATE_FILE="/tmp/hypr_desktop_state_${USER}"

if [ -f "$STATE_FILE" ]; then
    # Restore windows
    target_ws=$(cat "$STATE_FILE.ws")
    while read -r addr || [ -n "$addr" ]; do
        hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$target_ws\", window = \"address:$addr\", follow = false }))" >/dev/null
    done < "$STATE_FILE"
    rm -f "$STATE_FILE" "$STATE_FILE.ws"
else
    # Get active workspace ID
    active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    
    # Get all window addresses on this workspace
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $active_ws) | .address" > "$STATE_FILE"
    
    if [ ! -s "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
        exit 0
    fi
    
    echo "$active_ws" > "$STATE_FILE.ws"
    
    # Move them to hidden special workspace silently
    while read -r addr || [ -n "$addr" ]; do
        hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"special:minimized\", window = \"address:$addr\", follow = false }))" >/dev/null
    done < "$STATE_FILE"
fi

#!/bin/bash
# Strict Empty Workspace Deletion & Shift:
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
window_count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $active_ws)] | length")

if [ "$window_count" -eq 0 ]; then
    prev_ws=$((active_ws - 1))
    if [ "$prev_ws" -lt 1 ]; then
        prev_ws=1
    fi

    # Switch to previous workspace
    hyprctl dispatch workspace "$prev_ws"

    # Shift higher workspaces down by 1
    higher_workspaces=$(hyprctl workspaces -j | jq -r ".[] | select(.id > $active_ws) | .id" | sort -n)
    for ws in $higher_workspaces; do
        target_id=$((ws - 1))
        clients=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $ws) | .address")
        for addr in $clients; do
            if [ -n "$addr" ]; then
                hyprctl dispatch movetoworkspacesilent "$target_id,address:$addr"
            fi
        done
    done
fi

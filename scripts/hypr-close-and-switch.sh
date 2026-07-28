#!/bin/bash

# Get current workspace ID
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
clients=$(hyprctl clients -j)
window_count=$(echo "$clients" | jq "[.[] | select(.workspace.id == $active_ws)] | length")

if [ "$window_count" -gt 0 ]; then
    # Kill the focused window using native Lua dispatcher
    hyprctl eval 'hl.dispatch(hl.dsp.window.close())' >/dev/null 2>&1
    sleep 0.15
    # Re-check window count
    new_count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $active_ws)] | length")
    if [ "$new_count" -eq 0 ]; then
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "r-1" }))' >/dev/null 2>&1
    fi
else
    # Empty workspace -> switch back
    hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "r-1" }))' >/dev/null 2>&1
fi

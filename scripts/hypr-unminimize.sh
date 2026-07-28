#!/bin/bash
# Script to unminimize the most recently minimized window

# Find the window in special:minimized with the lowest focusHistoryID
last_minimized=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.name == "special:minimized")] | sort_by(.focusHistoryID) | .[0].address')

if [ -z "$last_minimized" ] || [ "$last_minimized" = "null" ]; then
    exit 0
fi

# Get the active workspace ID
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Move the window to the active workspace and focus it
hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$active_ws\", window = \"address:$last_minimized\" }))" >/dev/null
hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"address:$last_minimized\" }))" >/dev/null

#!/bin/bash

target_ws="$1"
if [ -n "$target_ws" ]; then
    active_addr=$(hyprctl activewindow -j | jq -r '.address')
    if [ -n "$active_addr" ] && [ "$active_addr" != "null" ]; then
        hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$target_ws\", window = \"address:$active_addr\", follow = true }))" >/dev/null 2>&1
    fi
fi

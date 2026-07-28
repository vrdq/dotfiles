#!/bin/bash
FLAG_FILE="/tmp/alt_tab_active"

if [ "$1" = "close" ]; then
    rm -f "$FLAG_FILE"
    dms ipc call hypr closeOverview >/dev/null 2>&1
    exit 0
fi

if [ ! -f "$FLAG_FILE" ]; then
    touch "$FLAG_FILE"
    dms ipc call hypr openOverview >/dev/null 2>&1
else
    if [ "$1" = "prev" ]; then
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))' >/dev/null 2>&1
    else
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))' >/dev/null 2>&1
    fi
fi

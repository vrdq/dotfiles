#!/bin/bash
# Set Wayland environment variables to guarantee connection from isolated systemd scopes
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

mkdir -p /home/vrdq/Pictures/Screenshots
FILE="/home/vrdq/Pictures/Screenshots/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

# Run spectacle in background mode to capture region and save to file
spectacle -r -b -n -o "$FILE"

# Copy the saved image file to the clipboard natively via wl-copy
if [ -f "$FILE" ]; then
    wl-copy < "$FILE"
fi

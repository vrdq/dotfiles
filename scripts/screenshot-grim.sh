#!/usr/bin/env bash
# Set Wayland environment variables to guarantee connection from isolated systemd scopes
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

SHOT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SHOT_DIR"
FILE="$SHOT_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

# Run spectacle or grim fallback in background mode to capture region
if command -v spectacle >/dev/null 2>&1; then
    spectacle -r -b -n -o "$FILE"
elif command -v grim >/dev/null 2>&1 && command -v slurp >/dev/null 2>&1; then
    if GEOM=$(slurp); then
        sleep 0.1
        grim -g "$GEOM" "$FILE"
    fi
fi

# Copy the saved image file to the clipboard natively via wl-copy
if [ -f "$FILE" ] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy < "$FILE"
fi

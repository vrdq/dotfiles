#!/bin/bash
# Smart launch wrapper that handles close-to-tray and minimized instances

CLASS="$1"
CMD="$2"

# Get active workspace ID
ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Check if there is a window for this class
CLIENT_INFO=$(hyprctl clients -j | jq -rc ".[] | select(.class == \"$CLASS\") | {address, workspace: .workspace.name}" | head -n 1)

if [ -n "$CLIENT_INFO" ]; then
    WINDOW_EXISTS=$(echo "$CLIENT_INFO" | jq -r '.address')
    WORKSPACE_NAME=$(echo "$CLIENT_INFO" | jq -r '.workspace')
else
    WINDOW_EXISTS=""
    WORKSPACE_NAME=""
fi

if [ -n "$WINDOW_EXISTS" ] && [ "$WINDOW_EXISTS" != "null" ]; then
    # If the window is minimized, pull it to the active workspace silently (unminimize)
    if [ "$WORKSPACE_NAME" = "special:minimized" ]; then
        hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$ACTIVE_WS\", window = \"address:$WINDOW_EXISTS\", follow = false }))" >/dev/null
    fi
    # Focus the window
    hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"address:$WINDOW_EXISTS\" }))" >/dev/null
else
    # Terminate background processes matching CMD, excluding this script's PID ($$)
    PIDS=$(pgrep -f "$CMD")
    for pid in $PIDS; do
        if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
            cmdline=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ')
            if [[ ! "$cmdline" =~ "smart-launch" ]] && [[ ! "$cmdline" =~ "bash" ]] && [[ ! "$cmdline" =~ "sh" ]]; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
    done
    sleep 0.1
    # Launch the application
    $CMD &
fi

#!/bin/bash
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "$1" in
    screen)
        grim "$FILE"
        ;;
    window)
        # Get active window geometry using hyprctl
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [ "$GEOM" = "null,null nullxnull" ] || [ -z "$GEOM" ]; then
            # Fallback to slurp if no active window
            GEOM=$(slurp)
        fi
        grim -g "$GEOM" "$FILE"
        ;;
    *)
        # Default is area selection
        if ! GEOM=$(slurp); then
            exit 1
        fi
        grim -g "$GEOM" "$FILE"
        ;;
esac

if [ -f "$FILE" ]; then
    wl-copy -t image/png < "$FILE"
    notify-send -a "Screenshot" -i "camera-photo" "Screenshot Saved" "Copied to clipboard and saved to Pictures/Screenshots"
fi

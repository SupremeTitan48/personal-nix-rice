#!/usr/bin/env bash
# Toggle Hyprland game mode: disables animations, blur, and shadows for
# maximum performance. Uses a flag file to track state across invocations.
set -euo pipefail

FLAGFILE=/tmp/hypr-gamemode

if [ -f "$FLAGFILE" ]; then
    rm "$FLAGFILE"
    hyprctl keyword animations:enabled 1
    hyprctl keyword decoration:blur:enabled 1
    hyprctl keyword decoration:shadow:enabled 1
    notify-send "Game Mode" "Disabled — normal mode restored" -t 2000
else
    touch "$FLAGFILE"
    hyprctl keyword animations:enabled 0
    hyprctl keyword decoration:blur:enabled 0
    hyprctl keyword decoration:shadow:enabled 0
    notify-send "Game Mode" "Enabled — animations and blur off" -t 2000
fi

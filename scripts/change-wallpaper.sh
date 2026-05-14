#!/usr/bin/env bash
# change-wallpaper.sh — set wallpaper, regenerate colors, reload all components
set -euo pipefail

WALLPAPER="${1:?Usage: change-wallpaper <path-to-image>}"
WALLPAPER="$(realpath "$WALLPAPER")"

if [[ ! -f "$WALLPAPER" ]]; then
  echo "Error: file not found: $WALLPAPER" >&2
  exit 1
fi

# 1. Set wallpaper with crossfade transition
swww img "$WALLPAPER" \
  --transition-type fade \
  --transition-duration 1 \
  --transition-fps 60

# 2. Generate Material You palette from the new wallpaper
matugen image "$WALLPAPER" --mode dark

# 3. Reload waybar colors (SIGUSR2 = reload config+CSS without restarting)
pkill -SIGUSR2 waybar 2>/dev/null || true

# 4. Reload hyprland (picks up updated hyprland-colors.conf via extraConfig source)
hyprctl reload 2>/dev/null || true

# 5. Restart swaync to pick up updated CSS (CSS is dynamic via matugen)
systemctl --user restart swaync 2>/dev/null || (pkill swaync 2>/dev/null; sleep 0.3; swaync &)

# 6. Reload kitty (USR1 = hot-reload config in all running kitty instances)
pkill -USR1 kitty 2>/dev/null || true

echo "Wallpaper changed and colors reloaded."

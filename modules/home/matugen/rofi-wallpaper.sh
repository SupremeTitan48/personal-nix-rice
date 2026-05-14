#!/usr/bin/env bash
# Rofi script-mode: lists wallpapers, runs change-wallpaper on selection
WALLPAPER_DIR="${HOME}/wallpapers"

if [[ -z "${ROFI_RETV:-}" ]]; then
  # First call: list available wallpapers
  find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) \
    | sort \
    | xargs -I{} basename {}
else
  # Second call: user selected an entry
  SELECTED="${1}"
  FULL_PATH="${WALLPAPER_DIR}/${SELECTED}"
  "${HOME}/.local/bin/change-wallpaper" "$FULL_PATH" &
fi

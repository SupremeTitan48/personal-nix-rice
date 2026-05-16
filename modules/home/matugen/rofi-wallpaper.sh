#!/usr/bin/env bash
WALLPAPER_DIR="${HOME}/wallpapers"

if [[ "${ROFI_RETV:-0}" -eq 0 ]]; then
  find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) \
    | sort \
    | while read -r fullpath; do
        basename="$(basename "$fullpath")"
        printf '%s\0icon\x1f%s\n' "$basename" "$fullpath"
      done
else
  SELECTED="${1}"
  FULL_PATH="${WALLPAPER_DIR}/${SELECTED}"
  "${HOME}/.local/bin/change-wallpaper" "$FULL_PATH" &
fi

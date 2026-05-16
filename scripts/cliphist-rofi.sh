#!/usr/bin/env bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-preview"
mkdir -p "$CACHE_DIR"

SELECTED=$(
  cliphist list | while IFS=$'\t' read -r idx content; do
    if [[ "$content" == \[\[* ]]; then
      thumb="$CACHE_DIR/$idx.png"
      if [[ ! -f "$thumb" ]]; then
        cliphist decode <<< "$idx	$content" 2>/dev/null \
          | convert - -thumbnail 64x64^ -gravity center -extent 64x64 "$thumb" 2>/dev/null || true
      fi
      if [[ -f "$thumb" ]]; then
        printf '%s\t%s\0icon\x1f%s\n' "$idx" "$content" "$thumb"
      else
        printf '%s\t%s\n' "$idx" "$content"
      fi
    else
      printf '%s\t%s\n' "$idx" "$content"
    fi
  done | rofi -dmenu -p "󰅇 Clipboard" -show-icons
)

[[ -n "$SELECTED" ]] && cliphist decode <<< "$SELECTED" | wl-copy

#!/usr/bin/env bash
# power-menu.sh — rofi-based power menu
# Bound to Super+Escape

entries="󰌾 Lock\n󰍃 Logout\n󰒲 Suspend\n󰑐 Reboot\n󰐥 Shutdown"

choice=$(printf "$entries" | rofi -dmenu -i -no-custom \
  -p "󰐥 Power" \
  -theme-str 'listview { lines: 5; } window { width: 240px; }')

case "$choice" in
  "󰌾 Lock")     hyprlock ;;
  "󰍃 Logout")   hyprctl dispatch exit 0 ;;
  "󰒲 Suspend")  systemctl suspend ;;
  "󰑐 Reboot")   systemctl reboot ;;
  "󰐥 Shutdown") systemctl poweroff ;;
esac

#!/usr/bin/env bash
# keybind-help.sh — show a searchable keybind reference via rofi
# Bind to Super+slash for instant access
rofi -dmenu -i -no-custom \
  -p "⌨  Keybinds" \
  -theme-str 'listview { lines: 20; }' \
  -mesg "Type to search  |  Esc to close" \
  << 'EOF'
── Applications ──────────────────────────────────────
Super + Return          Terminal (kitty)
Super + Space           App launcher (rofi)
Super + E               File manager (Thunar)
Super + W               Wallpaper picker → recolor all
Super + N               Notification center
Super + D               Toggle dock
Super + `               Workspace overview (hyprexpo)
── Power ─────────────────────────────────────────────
Super + Escape          Power menu (lock/logout/sleep…)
Super + Ctrl + L        Lock screen immediately
── Scratchpads ───────────────────────────────────────
Super + Alt + T         Terminal scratchpad
Super + Alt + O         Obsidian notes scratchpad
Super + Alt + M         System monitor scratchpad
── Windows ───────────────────────────────────────────
Super + Q               Close window
Super + F               Fullscreen
Super + Shift + Space   Toggle floating
Super + T               Toggle split direction
Super + R               Resize mode (HJKL / arrows)
Super + drag            Move floating window
Super + right-drag      Resize window
── Focus ─────────────────────────────────────────────
Super + H / L           Focus left / right
Super + K / J           Focus up / down
── Move Windows ──────────────────────────────────────
Super + Shift + H/L/K/J Move window
── Workspaces ────────────────────────────────────────
Super + 1–9             Switch workspace
Super + Shift + 1–9     Move window to workspace
Super + scroll          Cycle workspaces
── Window Switcher ───────────────────────────────────
Alt + Tab               Window switcher (rofi)
── Screenshots ───────────────────────────────────────
Print                   Screenshot → file
Super + Print           Screenshot region → annotate
Super + Shift + Print   Screenshot region → file
── Clipboard & Emoji ──────────────────────────────────
Super + V               Clipboard history
Super + .               Emoji picker
── Color ─────────────────────────────────────────────
(hyprpicker in terminal) Pick any screen color
── Media ─────────────────────────────────────────────
XF86AudioRaiseVolume    Volume up
XF86AudioLowerVolume    Volume down
XF86AudioMute           Mute toggle
XF86AudioPlay           Play / pause
XF86AudioNext/Prev      Next / previous track
XF86MonBrightness±      Brightness
EOF

#!/usr/bin/env bash
# usb-eject — rofi-based USB safe removal.
# Lists mounted hotplug block devices, lets user pick one,
# then unmounts and powers off via udisksctl.

get_mounts() {
  lsblk -o NAME,LABEL,SIZE,MOUNTPOINT,HOTPLUG -J 2>/dev/null | \
    python3 -c "
import json, sys
data = json.load(sys.stdin)
for dev in data.get('blockdevices', []):
    if not dev.get('hotplug'):
        continue
    children = dev.get('children', [dev])
    for child in children:
        mp = child.get('mountpoint') or ''
        if mp and mp != '[SWAP]':
            label = child.get('label') or child.get('name', '')
            size  = child.get('size', '')
            name  = child.get('name', '')
            print(f'/dev/{name}|{label or name} ({size}) at {mp}')
"
}

mounts=$(get_mounts)

if [ -z "$mounts" ]; then
  notify-send "USB Eject" "No removable drives mounted" -i media-removable
  exit 0
fi

selected=$(echo "$mounts" | awk -F'|' '{print $2}' | \
  rofi -dmenu -p "󰙱  Eject" \
       -theme-str 'window { width: 420px; } listview { lines: 6; }')

[ -z "$selected" ] && exit 0

devpath=$(echo "$mounts" | awk -F'|' -v sel="$selected" '$2 == sel {print $1}')

if udisksctl unmount -b "$devpath" --no-user-interaction 2>/dev/null; then
  udisksctl power-off -b "$devpath" --no-user-interaction 2>/dev/null || true
  notify-send "USB Eject" "Safely removed: $selected" -i media-removable
else
  notify-send "USB Eject" "Failed to unmount: $selected" -u critical -i dialog-error
fi

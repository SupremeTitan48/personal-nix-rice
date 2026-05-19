# Rice Improvements — Implementation Plan

> Researched from: fufexan/dotfiles, JaKooLit/Hyprland-Dots, prasanthrangan/hyprdots,
> end-4/dots-hyprland, iynaix/dotfiles — May 2026.
> Research agent verified exact source URLs and code. Plan updated accordingly.
> Status: **PENDING REVIEW** — no code has been written yet.

---

## Feature List (final, prioritised)

| # | Feature | Priority | Risk |
|---|---------|----------|------|
| 1 | `custom/stats` waybar script (CPU% + RAM%) | High | Low |
| 2 | Blur quality: passes 3, `special`, `popups` | High | Low |
| 3 | Accent-colored shadows via matugen | Medium | Low |
| 4 | Bluetuith TUI integration | Medium | Low |
| 5 | USB eject rofi script | Medium | Low |
| 6 | Hyprlock: avatar fallback + greeting label | Low | Low |
| 7 | Fix deprecation warnings | Low | Low |

Items deliberately excluded:
- CPU/GPU **temperatures** — user explicitly removed them
- GPU usage % — user said remove repeated widgets, keep it minimal
- Quickshell/AGS — saved in `memory/project_ui_future_improvements.md`
- Spring animations (Lua API) — saved in future improvements memory

---

## 1. `custom/stats` — Consolidated Waybar Stats Widget

### What the top rices do

**fufexan** (Quickshell `bar/Resources.qml`): Two-column widget showing `CPU%` and
`MEM%`. Reads from a `ResourcesState` QML singleton that polls `/proc/stat` and
`/proc/meminfo`. No temps, no GPU in bar.

```qml
// fufexan bar/Resources.qml (simplified)
HoverTooltip { text: ResourcesState.cpu_freq
  ColumnLayout {
    Text { text: "CPU" }
    Text { text: ResourcesState.cpu_percent + "%" }
  }
}
HoverTooltip { text: ResourcesState.mem_used
  ColumnLayout {
    Text { text: "MEM" }
    Text { text: ResourcesState.mem_percent + "%" }
  }
}
```

**prasanthrangan** (hyprdots): Separate `cpuinfo.sh` and `gpuinfo.sh` scripts in
`~/.local/share/bin/`. Each outputs JSON. Clean but still keeps them as separate modules
(`cpu memory custom/cpuinfo custom/gpuinfo` all visible). Too verbose.

**Our approach**: Single `waybar-stats` bash script → one JSON blob → one `custom/stats`
module. Same philosophy as fufexan, adapted for waybar's JSON custom module format.

### Script to create: `scripts/waybar-stats.sh`

fufexan's approach (via his Quickshell ResourcesState.qml) uses:
- CPU: `top -bn1 | grep '%Cpu' | awk '{print 100-$8}'`
- RAM: `free | awk 'NR==2{print $3/$2*100}'`

For waybar's JSON custom module format we write an equivalent bash script:

```bash
#!/usr/bin/env bash
# Outputs waybar-compatible JSON with CPU and RAM usage.
# CPU: sampled via top -bn1 (matches fufexan's ResourcesState approach).

# --- CPU --- (top -bn1 one-shot, no sleep needed)
cpu=$(top -bn1 | awk '/^%Cpu/{print int(100 - $8)}' 2>/dev/null || echo 0)

# --- RAM ---
mem_total=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
mem_avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
mem_used=$(( mem_total - mem_avail ))
mem_pct=$(( mem_used * 100 / mem_total ))
mem_gib=$(awk "BEGIN{printf \"%.1f\", $mem_used/1048576}")
mem_total_gib=$(awk "BEGIN{printf \"%.1f\", $mem_total/1048576}")

# --- Output ---
text="󰻠 ${cpu}%  ${mem_pct}%"
tooltip="CPU: ${cpu}%\nRAM: ${mem_gib}G / ${mem_total_gib}G"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
```

### Waybar module (already added to `modules/home/waybar/default.nix`)

```nix
"custom/stats" = {
  exec = "${config.home.homeDirectory}/.local/bin/waybar-stats";
  return-type = "json";
  interval = 3;
  format = "{}";
};
```

### home.file wiring (to add to `modules/home/hyprland/default.nix` or a dedicated scripts.nix)

```nix
home.file.".local/bin/waybar-stats" = {
  source = ../../../scripts/waybar-stats.sh;
  executable = true;
};
```

### Implementation steps
1. Create `scripts/waybar-stats.sh` with script above
2. Add `home.file.".local/bin/waybar-stats"` entry in `modules/home/hyprland/default.nix`
3. Confirm `modules-right` in waybar is already updated to `[ "custom/stats" "pulseaudio" "network" "custom/swaync" "tray" ]`
4. Remove leftover `memory`, `cpu`, `temperature`, `disk`, `custom/gpu` module blocks from `waybar/default.nix`

---

## 2. Blur Quality Improvements

### What the top rices do

**JaKooLit** (`UserDecorations.conf` — confirmed):
```conf
blur {
    enabled = true
    size = 6
    passes = 3
    new_optimizations = true
    xray = true             # JaKooLit uses xray too
    ignore_opacity = true   # JaKooLit enables this
    special = true
    popups = true
}
```

**fufexan** (Lua config, confirmed):
```lua
blur = {
    passes = 4, size = 7, popups = true, popups_ignorealpha = 0.2
}
```
fufexan goes to 4 passes; JaKooLit uses 3. We'll use 3 — safer with AMD iGPU,
still a clear quality jump over our current 2.

JaKooLit also enables `ignore_opacity = true` which helps the blur show through
semi-transparent waybar backgrounds. We currently have `ignore_opacity = false`.
Recommend enabling this.

### Change: `modules/home/hyprland/default.nix`

In the `settings.decoration.blur` attrset:
```nix
blur = {
  enabled = true;
  size = 8;
  passes = 3;            # was 2
  xray = true;           # keep — wallpaper bleed-through for glassmorphism
  ignore_opacity = true; # was false — enables blur through semi-transparent layers
  popups = true;         # add — blurs right-click menus, tooltips
  special = true;        # add — blurs special workspace background
};
```

### Implementation steps
1. Edit `modules/home/hyprland/default.nix`: change `passes = 2` → `passes = 3`
2. Change `ignore_opacity = false` → `ignore_opacity = true`
3. Add `popups = true;` and `special = true;` to the `blur` block

---

## 3. Accent-Colored Shadows via Matugen

### What the top rices do

**JaKooLit** (`UserDecorations.conf` — confirmed):
```conf
shadow {
    enabled = true
    range = 3
    render_power = 1
    color = $color12         # wallust (not matugen) accent color
    color_inactive = $color10
}
```
JaKooLit uses wallust for theming, not matugen. `$color12` is a fully-saturated accent.

**fufexan**: `color = "rgba(00000020)"` — nearly invisible dark shadow. Too subtle.

**end-4** (matugen user, confirmed): Does NOT include shadow color in his matugen
template. Hardcodes it. No rice was found that wires a matugen accent into shadow.

**Our approach**: This is an original improvement — we know the matugen template
syntax, so we add it ourselves. Using 33% alpha (`55` hex) makes it visible and
accent-tinted without being garish. We raise JaKooLit's `range = 3` to our
current `range = 30` (which gives the visible glow), keep `render_power = 3`.

### Template change: `modules/home/matugen/templates/hyprland-colors.conf`

Add one variable:
```conf
$accent_shadow    = rgba({{colors.primary.dark.hex_stripped}}55)
```
(55 hex = 33% alpha — matches our current shadow opacity, now accent-tinted)

### Hyprland change: `modules/home/hyprland/default.nix`

The `settings.decoration.shadow.color` is set to `"rgba(00000055)"`. Override it in
`extraConfig` (which is appended after settings, so it wins):

```conf
decoration {
  shadow {
    color = $accent_shadow
    color_inactive = rgba(00000033)
  }
}
```

This goes in the `extraConfig` string, inside the existing `general { ... }` section
or as its own `decoration { ... }` block.

### Implementation steps
1. Edit `modules/home/matugen/templates/hyprland-colors.conf`: add `$accent_shadow` line
2. Edit `modules/home/hyprland/default.nix` `extraConfig`: add decoration shadow override
3. After build, run `matugen image ~/wallpapers/default.png --mode dark` to regenerate

---

## 4. Bluetuith TUI Integration

### What the top rices do

No top rice uses bluetuith directly — most use `blueman-applet` (tray) or nothing.
JaKooLit uses blueman. fufexan has a Bluetooth.qml in the Quickshell bar that
calls `rfkill toggle bluetooth`.

**Our approach**: Floating Kitty window running `bluetuith` TUI, toggled via scratchpad
keybind. Already removed `blueman-applet` from exec-once (it's still in packages).
`bluetuith` replaces the applet for device management.

### Package + exec: `modules/home/hyprland/default.nix`

Add to `home.packages`:
```nix
bluetuith
```

Remove `blueman` from `home.packages` (or keep it — `blueman-applet` exec-once is already
gone, but the package provides `blueman-manager` as a fallback GUI).

### Keybind: `modules/home/hyprland/keybinds.nix`

```conf
bind = $mod ALT, B, togglespecialworkspace, bluetooth
```

### Hyprland exec-once: `modules/home/hyprland/default.nix` `extraConfig`

```conf
exec-once = [workspace special:bluetooth silent] kitty --class=kitty-bluetuith bluetuith
```

### Windowrule: `modules/home/hyprland/rules.nix` (check file for existing pattern)

```conf
windowrulev2 = float,          class:^(kitty-bluetuith)$
windowrulev2 = size 700 500,   class:^(kitty-bluetuith)$
windowrulev2 = center,         class:^(kitty-bluetuith)$
windowrulev2 = animation slide, class:^(kitty-bluetuith)$
```

### Workspace icon: `modules/home/waybar/default.nix`

In `window-rewrite`:
```nix
"class<kitty-bluetuith>" = "󰂯";
```

### Implementation steps
1. Add `bluetuith` to `home.packages` in `modules/home/hyprland/default.nix`
2. Remove `blueman` from packages (optional — keep if you want the full GUI fallback)
3. Add `exec-once` for bluetuith special workspace in `extraConfig`
4. Add `$mod ALT, B` keybind in `keybinds.nix`
5. Add windowrules in `rules.nix`
6. Add icon to waybar workspace `window-rewrite`

---

## 5. USB Eject Rofi Script

### What the top rices do

No top rice has a clean USB eject rofi script. fufexan uses `udiskie` in tray (same as us).
JaKooLit has a generic logout/power script but nothing for USB.

**Our approach**: Simple rofi-based USB eject. Lists block devices that are mounted but
not system drives, lets user pick one, calls `udisksctl unmount` + `udisksctl power-off`.

### Script to create: `scripts/usb-eject.sh`

```bash
#!/usr/bin/env bash
# Rofi USB eject script — lists removable mounted block devices

# Get mounted removable drives (exclude root, nvme system drives)
get_mounts() {
  lsblk -o NAME,LABEL,SIZE,MOUNTPOINT,HOTPLUG -J 2>/dev/null | \
    python3 -c "
import json, sys
data = json.load(sys.stdin)
for dev in data.get('blockdevices', []):
    # Only hotplug devices
    if not dev.get('hotplug'):
        continue
    children = dev.get('children', [dev])
    for child in children:
        mp = child.get('mountpoint') or ''
        if mp and mp != '[SWAP]':
            label = child.get('label') or child.get('name', '')
            size  = child.get('size', '')
            name  = child.get('name', '')
            print(f'/dev/{name}|{label or name} ({size}) → {mp}')
"
}

mounts=$(get_mounts)

if [ -z "$mounts" ]; then
  notify-send "USB Eject" "No removable drives mounted" -i media-removable
  exit 0
fi

# Show rofi picker
selected=$(echo "$mounts" | awk -F'|' '{print $2}' | \
  rofi -dmenu -p "󰙱  Eject" \
       -theme-str 'window { width: 400px; } listview { lines: 6; }')

[ -z "$selected" ] && exit 0

# Find the /dev/... path for the selected label
devpath=$(echo "$mounts" | awk -F'|' -v sel="$selected" '$2 == sel {print $1}')

if udisksctl unmount -b "$devpath" 2>/dev/null; then
  udisksctl power-off -b "$devpath" 2>/dev/null || true
  notify-send "USB Eject" "Safely removed: $selected" -i media-removable
else
  notify-send "USB Eject" "Failed to unmount: $selected" -u critical -i dialog-error
fi
```

### Keybind: `modules/home/hyprland/keybinds.nix`

```conf
bind = $mod, U, exec, bash ${config.home.homeDirectory}/.local/bin/usb-eject
```

### home.file wiring: `modules/home/hyprland/default.nix`

```nix
home.file.".local/bin/usb-eject" = {
  source = ../../../scripts/usb-eject.sh;
  executable = true;
};
```

### Packages needed

`python3` (already available system-wide on NixOS), `udisks2` (already enabled via
`services.udisks2.enable = true` if udiskie is configured — check `hosts/desktop/default.nix`).

### Implementation steps
1. Create `scripts/usb-eject.sh`
2. Add `home.file.".local/bin/usb-eject"` in `modules/home/hyprland/default.nix`
3. Add `$mod, U` keybind in `keybinds.nix`
4. Verify `udisks2` service is enabled in host config

---

## 6. Hyprlock: Avatar Fallback + Greeting Label

### What the top rices do

**JaKooLit** (`hyprlock.conf` — confirmed): The entire `image {}` block is commented out.
They skip the avatar rather than risk a broken image path.

**fufexan** (confirmed): No image block at all. Clock + date + password only.

**end-4** (confirmed): No image block. Uses a shell script for battery/status text instead.

**iynaix** (confirmed): Handles this at the **Nix level** — deploys `avatar.png` from
the repo directly to `~/.face`:
```nix
hj.files.".face".source = ../../avatar.png;
```
Hyprlock's image block always works because the file is guaranteed to exist at deploy time.
This is the cleanest approach — no runtime conditional logic needed in hyprlock.

**Our approach** (iynaix pattern): Deploy a fallback avatar via `home.file` with
`force = false` so it won't overwrite a user's custom photo:

```nix
home.file.".face" = {
  source = ../../../assets/default-face.png;
  force = false;   # user's own ~/.face takes precedence
};
```

The image at `assets/default-face.png` should be a 200×200 PNG.

**Greeting label**: Add a "Good morning / Good afternoon / Good evening" greeting below
the clock:

```nix
{
  monitor = "";
  text = ''cmd[update:60000] echo "$(case $(date +%H) in
    0[0-9]|1[01]) echo 'Good morning' ;;
    1[2-7]) echo 'Good afternoon' ;;
    *) echo 'Good evening' ;;
  esac), ${userConfig.username}"'';
  color = "$text_muted";
  font_size = 14;
  font_family = "JetBrainsMono Nerd Font";
  position = "0, 55";
  halign = "center";
  valign = "center";
}
```

This is a low-priority polish item. The clock + date are already present and working.

### Implementation steps
1. Add a default face PNG to `assets/default-face.png`
2. Add `home.file.".face"` with `force = false` in hyprlock or a dedicated module
3. Optionally add the greeting label to `hyprlock/default.nix`

---

## 7. Fix Deprecation Warnings

These need verification against the actual `nixos-rebuild` output. Known warnings:

### a) GTK 4 theme warning

`home-manager` recently changed the GTK 4 theme attribute. Check if we have:
```nix
gtk.gtk4.theme = ...
```
vs. the correct form. If using `stylix`, it handles this automatically.

### b) `configType` warning (if present)

Some Nix module options changed from `types.lines` to `types.str`. Usually
auto-corrects, but may emit a warning.

### c) `fontconfig.enable = false` (if disabled)

We have `fonts.fontconfig.enable = false` in some file. The recommended pattern
on NixOS 24.11+ is to leave this unset or true. Check and remove the `= false`.

### Implementation steps
1. Run `nixos-rebuild build 2>&1 | grep -i warn` to capture current warnings
2. Fix each warning by following the suggested attribute paths
3. Run again to confirm zero warnings

---

## Implementation Order

Suggested order of commits (each is self-contained and safe to build independently):

```
Commit 1: custom/stats script + waybar cleanup (remove dead modules)
Commit 2: Blur quality (passes=3, popups, special)
Commit 3: Accent shadow via matugen template
Commit 4: Bluetuith integration
Commit 5: USB eject script
Commit 6: Hyprlock avatar fallback
Commit 7: Fix deprecation warnings
```

---

## What's Already Done (staged/uncommitted in worktree)

- `modules/home/waybar/default.nix`:
  - `modules-right` updated to `["custom/stats" "pulseaudio" "network" "custom/swaync" "tray"]`
  - `custom/stats` module block added, referencing `~/.local/bin/waybar-stats`
  - Dead modules (gpu, memory, cpu, temperature, disk) blocks still present in file — need removal
- 3-pill waybar CSS (`modules/home/waybar/style.css`) — complete
- swaync control center config (`modules/home/notifications.nix`) — complete
- MD3 animations (`modules/home/hyprland/animations.nix`) — complete
- Font consistency (rofi, hyprlock all use JetBrainsMono Nerd Font) — complete
- Power menu script with correct glyphs — complete
- Shadow value from fufexan (`rgba(00000055)`) — complete
- networkmanager_dmenu replacing nm-applet — complete

---

*Review this doc, then say "implement" to proceed with Commit 1.*

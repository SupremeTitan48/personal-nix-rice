# nix-rice

NixOS + Hyprland desktop config. Glassmorphism aesthetic with Material You colors derived from your wallpaper.

**Hardware target:** NVIDIA RTX 3070 · Ryzen 5 5600X · 2560×1440@240 (GSync)

![Stack](https://img.shields.io/badge/NixOS-unstable-blue) ![Compositor](https://img.shields.io/badge/compositor-Hyprland-purple) ![License](https://img.shields.io/badge/license-MIT-green)

---

## What's included

| Component | Choice |
|---|---|
| Compositor | Hyprland (own flake, latest) |
| Bar | Waybar — floating glass pill |
| Launcher | Rofi-wayland — glass panel + wallpaper picker |
| Terminal | Kitty + Fish + Starship |
| Notifications | swaync |
| Lock screen | Hyprlock |
| Wallpaper | swww (crossfade transitions) |
| Color pipeline | matugen (Material You from wallpaper) |
| GTK theme | adw-gtk3-dark + Papirus-Dark icons + Bibata-Modern-Ice cursor |
| Gaming | Steam · Gamemode · Gamescope · MangoHud · Heroic · Lutris |
| Apps | Google Chrome · VSCodium · Thunar |

---

## Before you install

### 1. Generate hardware config

On your target machine, run:

```bash
nixos-generate-config --show-hardware-config > hosts/desktop/hardware.nix
```

Replace the placeholder `hosts/desktop/hardware.nix` with this output.

### 2. Set your timezone

Edit `modules/nixos/locale.nix` and set your timezone:

```nix
time.timeZone = "America/Chicago";  # change this
```

### 3. Check your monitor connector

Run `wlr-randr` or `hyprctl monitors` to find your connector name, then update `modules/home/hyprland/monitors.nix`:

```nix
monitor = DP-1, 2560x1440@240, 0x0, 1  # DP-1 may differ on your machine
```

### 4. Add a wallpaper

Drop a dark wallpaper image into `wallpapers/`:

```bash
cp ~/your-wallpaper.jpg wallpapers/default.jpg
```

Matugen derives the initial accent color from this on first login. Any subsequent wallpaper can be set with `Super+W`.

---

## Install

Clone the repo to `/etc/nixos` (or wherever you manage your config):

```bash
git clone https://github.com/SupremeTitan48/personal-nix-rice /etc/nixos
cd /etc/nixos
```

Complete the steps above, then apply:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

Log out, select the Hyprland session in SDDM, and log back in.

---

## Keybinds

| Key | Action |
|---|---|
| `Super + Return` | Terminal (kitty) |
| `Super + Space` | App launcher (rofi) |
| `Super + W` | Wallpaper picker → recolors everything |
| `Super + N` | Notification center |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Shift + Space` | Toggle floating |
| `Super + H/J/K/L` | Focus window |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + 1–9` | Switch workspace |
| `Super + Shift + 1–9` | Move window to workspace |
| `Super + Ctrl + L` | Lock screen |
| `Super + V` | Clipboard history |
| `Print` | Screenshot (fullscreen) |
| `Super + Print` | Screenshot (region) |

---

## Wallpaper & color pipeline

Changing the wallpaper recolors the entire desktop in about one second:

```
change-wallpaper.sh <path>
  → swww crossfade transition
  → matugen generates Material You palette
  → waybar, rofi, kitty, swaync, hyprland borders all reload
```

The wallpaper picker (`Super+W`) shows everything in `~/Pictures/Wallpapers/` and `~/.config/wallpapers/` via rofi, then calls this script automatically.

To change wallpaper manually:

```bash
~/.local/bin/change-wallpaper ~/path/to/image.jpg
```

---

## File structure

```
flake.nix                        # inputs + system definition
hosts/desktop/
  default.nix                    # host entry point, imports all modules
  hardware.nix                   # generated — replace with nixos-generate-config output
modules/nixos/                   # system-level NixOS modules
  nvidia.nix                     # proprietary drivers, modesetting, Wayland env
  boot.nix                       # systemd-boot, kernel params, latest kernel
  audio.nix                      # PipeWire + WirePlumber
  gaming.nix                     # Steam, Gamemode, Gamescope, MangoHud
  portal.nix                     # xdg-desktop-portal (screencasting + file picker)
  display-manager.nix            # SDDM Wayland
  fonts.nix / locale.nix / network.nix
modules/home/                    # Home Manager modules (per-user config)
  hyprland/                      # compositor config, keybinds, rules, animations, monitors
  waybar/                        # bar layout + glassmorphism CSS
  rofi/                          # launcher config + CSS
  hyprlock/                      # lock screen
  matugen/                       # color templates + wallpaper script
  swww/                          # wallpaper daemon autostart
  terminal.nix                   # kitty + fish + starship
  notifications.nix              # swaync
  theme.nix                      # GTK/Qt/cursor/icons
  apps.nix                       # Chrome, VSCodium
  gaming.nix                     # Heroic, ProtonUp-Qt
  clipboard.nix / screenshot.nix / filemanager.nix
home/jkoch/default.nix           # imports all home modules for jkoch
wallpapers/                      # drop wallpapers here; default.jpg used on first boot
scripts/change-wallpaper.sh      # wallpaper + recolor pipeline
```

---

## Customization

**Change accent color source:** swap out `wallpapers/default.jpg` and run `change-wallpaper.sh` once.

**Add a second monitor:** add a line to `modules/home/hyprland/monitors.nix`.

**Adjust gaps/borders:** `modules/home/hyprland/default.nix` — `gaps_in`, `gaps_out`, `rounding`, `border_size`.

**Tune animations:** `modules/home/hyprland/animations.nix`.

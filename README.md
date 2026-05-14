# nix-rice

A daily-driver NixOS + Hyprland desktop built for stability, rollback safety, and a glassmorphism aesthetic where every color is derived from your wallpaper via Google's Material You algorithm.

**Hardware target:** NVIDIA RTX 3070 · Ryzen 5 5600X · 2560×1440@240Hz GSync

---

## Stack

| Layer | Choice |
|---|---|
| OS | NixOS (unstable channel, flakes) |
| Compositor | Hyprland + UWSM session management |
| Bar | Waybar — floating glass pill |
| Launcher | Rofi-wayland — glass panel + wallpaper picker |
| Terminal | Kitty + Fish + Tide prompt |
| Notifications | swaync |
| Lock screen | Hyprlock |
| Wallpaper daemon | swww (crossfade transitions) |
| Color engine | matugen (Material You from wallpaper) |
| GTK theme | adw-gtk3-dark + Papirus-Dark + Bibata-Modern-Ice cursor |
| Night light | wlsunset |
| Gaming | Steam · Gamemode · Gamescope · MangoHud · Heroic · Lutris |
| Apps | Google Chrome · VSCodium · Thunar · mpv · imv |

---

## How the color pipeline works

This is the core idea of the rice. Every color on the desktop — window borders, the bar, the launcher, the terminal, the lock screen, notifications — is derived from a single wallpaper image at runtime. Changing the wallpaper recolors everything in about one second.

```
wallpaper image
    │
    ▼
matugen (Google's Material You algorithm)
    │  generates a tonal palette from dominant hues
    ▼
per-app color files written to ~/.cache/matugen/
    ├── waybar-colors.css
    ├── rofi-colors.rasi
    ├── kitty-colors.conf
    ├── hyprland-colors.conf   ← window border accent
    ├── swaync-colors.css
    └── hyprlock-colors.conf
    │
    ▼
change-wallpaper.sh reloads each component:
    swww img (crossfade) → matugen → waybar SIGUSR2
    → hyprctl reload → swaync restart → kitty USR1
```

On first login, before you've ever set a wallpaper, stub color files are written automatically so nothing crashes.

---

## Prerequisites

- NixOS installed (any recent version — you will switch to unstable)
- Git
- A dark wallpaper image (`.jpg` or `.png`)
- NVIDIA GPU (RTX series) — other GPUs need changes to `modules/nixos/nvidia.nix`

---

## Installation

### Step 1 — Clone the repo

Clone it wherever you keep your NixOS config. `/etc/nixos` is the standard location, but `~/nix-config` or similar also works fine.

```bash
sudo git clone https://github.com/SupremeTitan48/personal-nix-rice /etc/nixos
cd /etc/nixos
```

### Step 2 — Generate your hardware config

The placeholder `hosts/desktop/hardware.nix` must be replaced with your actual hardware configuration. Run this on your target machine:

```bash
nixos-generate-config --show-hardware-config | sudo tee hosts/desktop/hardware.nix
```

This generates UUIDs for your partitions, detects your CPU/GPU, and sets the correct filesystem options. Do not skip this step — the placeholder will not boot on your machine.

### Step 3 — Set your username

The config is set up for user `jkoch`. To use a different username, replace it throughout:

```bash
# Preview what would change
grep -r "jkoch" --include="*.nix" -l

# Replace (adjust to your username)
find . -name "*.nix" -exec sed -i 's/jkoch/yourusername/g' {} +
```

Also rename the home directory:

```bash
mv home/jkoch home/yourusername
```

### Step 4 — Set your timezone

Edit `modules/nixos/locale.nix`:

```nix
time.timeZone = "America/Chicago";  # find yours: timedatectl list-timezones
i18n.defaultLocale = "en_US.UTF-8";
```

### Step 5 — Add a default wallpaper

Matugen needs an image to derive colors from on first boot. Drop a dark wallpaper into the repo:

```bash
cp ~/your-wallpaper.jpg wallpapers/default.jpg
```

Any image format works (jpg, png, webp). Dark images produce better glassmorphism results since the surface colors are already near-black.

### Step 6 — Apply the configuration

```bash
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

This will take a while on the first run — it builds the kernel, Hyprland, and all packages from source or downloads them from the binary cache. Subsequent updates are much faster.

### Step 7 — Log in

Reboot (or log out), select **Hyprland** in the SDDM session picker, and log in.

On first login:
- The wallpaper loads from `~/wallpapers/default.jpg`
- matugen generates your color palette
- All components reload with the derived colors

---

## Verify your monitor connector

Before or after logging in, check your monitor's connector name:

```bash
# From a TTY or SSH session:
wlr-randr

# Or from within Hyprland:
hyprctl monitors
```

Look for a line like `DP-1`, `HDMI-A-1`, `DP-3`, etc. If it's not `DP-1`, update `modules/home/hyprland/monitors.nix`:

```nix
monitor = [
  "DP-1, 2560x1440@240, 0x0, 1"   # change DP-1 to your connector
];
```

Then rebuild: `nrs`

---

## Keybinds

### Applications

| Key | Action |
|---|---|
| `Super + Return` | Terminal (kitty) |
| `Super + Space` | App launcher (rofi) |
| `Super + E` | File manager (thunar) |
| `Super + W` | Wallpaper picker → recolors everything |
| `Super + N` | Notification center toggle |
| `` Super + ` `` | Workspace overview (hyprexpo) |

### Windows

| Key | Action |
|---|---|
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Shift + Space` | Toggle floating |
| `Super + T` | Toggle split direction |
| `Super + R` | Resize mode (then arrow keys or HJKL, `Esc` to exit) |
| `Super + mouse drag` | Move floating window |
| `Super + right-click drag` | Resize window |

### Focus & movement

| Key | Action |
|---|---|
| `Super + H/J/K/L` | Focus window left/down/up/right |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + 1–9` | Switch workspace |
| `Super + Shift + 1–9` | Move window to workspace |
| `Super + mouse scroll` | Cycle workspaces |
| `` Super + Alt + ` `` | Toggle scratchpad workspace |
| `` Super + Shift + ` `` | Send window to scratchpad |

### System

| Key | Action |
|---|---|
| `Super + Ctrl + L` | Lock screen |
| `Super + V` | Clipboard history (cliphist → rofi) |
| `Print` | Screenshot fullscreen → saved to `~/Pictures/screenshots/` |
| `Super + Print` | Screenshot region → open in satty for annotation |
| `Super + Shift + Print` | Screenshot region → saved directly |

### Media & volume

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up (with OSD) |
| `XF86AudioLowerVolume` | Volume down (with OSD) |
| `XF86AudioMute` | Mute toggle |
| `XF86AudioMicMute` | Mic mute toggle |
| `XF86AudioPlay` | Play/pause |
| `XF86AudioNext / Prev` | Next/previous track |
| `XF86MonBrightnessUp/Down` | Brightness (with OSD) |

---

## Changing the wallpaper

### Via the picker (recommended)

`Super + W` opens rofi showing all images in `~/wallpapers/`. Selecting one:
1. Fades the wallpaper in via swww
2. Runs matugen to generate a new color palette
3. Reloads waybar, hyprland, kitty, swaync with the new colors

Total time: ~1 second.

### From the terminal

```bash
change-wallpaper ~/Pictures/some-image.jpg
```

You can use any image on the filesystem — it doesn't need to live in `~/wallpapers/`. To add it to the picker, copy it there:

```bash
cp ~/Pictures/some-image.jpg ~/wallpapers/
```

---

## Updating

```bash
cd ~/personal-nix-rice   # or wherever the repo lives
nix flake update         # bumps all inputs (Hyprland, nixpkgs, etc.)
nrs                      # alias for: sudo nixos-rebuild switch --flake .#desktop
```

To update only a specific input (e.g. Hyprland without touching nixpkgs):

```bash
nix flake update hyprland
nrs
```

To roll back a bad update:

```bash
sudo nixos-rebuild switch --rollback
# or pick a specific generation:
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --switch-generation <N>
```

---

## Customization

### Gaps, borders, rounding

`modules/home/hyprland/default.nix`:

```nix
general = {
  gaps_in = 6;       # gap between windows
  gaps_out = 12;     # gap between windows and screen edge
  border_size = 2;   # window border thickness
};

decoration = {
  rounding = 12;     # corner radius
};
```

### Animations

`modules/home/hyprland/animations.nix` — timing curves and durations for window open/close, workspace switch, etc.

### Adding a second monitor

`modules/home/hyprland/monitors.nix` — add a second `monitor =` line:

```nix
monitor = [
  "DP-1, 2560x1440@240, 0x0, 1"
  "HDMI-A-1, 1920x1080@60, 2560x0, 1"  # positioned to the right
];
```

### Waybar layout

`modules/home/waybar/default.nix` — the `modules-left`, `modules-center`, `modules-right` lists control what appears in the bar.

### Night light

`modules/home/nightlight.nix` — update the coordinates for your location:

```nix
services.wlsunset = {
  latitude = "41.8";   # your latitude
  longitude = "-87.6"; # your longitude
  temperature.day = 6500;
  temperature.night = 3500;
};
```

### Adding packages

- System packages (available to all users, in PATH): `hosts/desktop/default.nix` → `environment.systemPackages`
- User packages: `home/jkoch/default.nix` → `home.packages`

---

## Troubleshooting

### Black screen after login

Usually an NVIDIA issue. Drop to a TTY (`Ctrl+Alt+F2`) and check:

```bash
journalctl -b -u display-manager
hyprctl instances   # should show a running instance
```

Common fixes:
- Verify `hardware.nvidia.modesetting.enable = true` in `modules/nixos/nvidia.nix`
- Verify `nvidia-drm.modeset=1` is in `boot.kernelParams` in `modules/nixos/boot.nix`
- Try switching between `hardware.nvidia.open = true` and `open = false`

### Cursor invisible or flickering

NVIDIA software cursor quirk. In `modules/home/hyprland/default.nix`:

```nix
cursor = {
  no_hardware_cursors = true;
  use_cpu_buffer = true;
};
```

Both options should already be set. If the cursor is still broken, verify the `XCURSOR_THEME` and `XCURSOR_SIZE` vars are in `~/.config/uwsm/env-hyprland`.

### Waybar not loading / blank bar

```bash
waybar &   # run manually to see errors
journalctl --user -u waybar
```

Usually a CSS syntax error from a matugen color file. Check `~/.cache/matugen/waybar-colors.css` exists — if not, run `change-wallpaper ~/wallpapers/default.jpg` to regenerate.

### Screen sharing not working

Both portals must be running:

```bash
systemctl --user status xdg-desktop-portal-hyprland
systemctl --user status xdg-desktop-portal-gtk
```

If either is failed: `systemctl --user restart xdg-desktop-portal`

### Colors not updating after wallpaper change

The color pipeline requires matugen to be in PATH. Verify:

```bash
which matugen
matugen image ~/wallpapers/default.jpg --mode dark
```

Then check `~/.cache/matugen/` for the generated files.

### Audio not working

```bash
systemctl --user status pipewire pipewire-pulse wireplumber
pactl info   # should show PipeWire as the server
```

### Git commits failing (no identity)

The `programs.git` config sets your identity. If you changed the username in Step 3, also update `modules/home/git.nix`:

```nix
programs.git = {
  userName = "Your Name";
  userEmail = "your@email.com";
};
```

Then rebuild: `nrs`

---

## File structure

```
flake.nix                         # flake inputs + system definition
flake.lock                        # pinned input versions

hosts/
  desktop/
    default.nix                   # host entry — imports all NixOS modules
    hardware.nix                  # REPLACE with nixos-generate-config output

modules/
  nixos/                          # system-level NixOS configuration
    nvidia.nix                    # open kernel module, modesetting, VAAPI
    boot.nix                      # systemd-boot, kernel params, linuxPackages_latest
    audio.nix                     # PipeWire + WirePlumber, low-latency config
    gaming.nix                    # Steam, Gamemode, Gamescope, MangoHud, sysctl
    portal.nix                    # xdg-desktop-portal (screencasting + file picker)
    display-manager.nix           # SDDM Wayland + sddm-astronaut theme
    nix.nix                       # Cachix, GC, store optimise, registry pin
    fonts.nix                     # system-wide font packages
    locale.nix                    # timezone, locale, keyboard layout
    network.nix                   # NetworkManager, Bluetooth, systemd-resolved

  home/                           # Home Manager (per-user configuration)
    hyprland/
      default.nix                 # core config, exec-once, NVIDIA env, blur
      keybinds.nix                # all keybind declarations
      rules.nix                   # window rules, workspace assignments
      animations.nix              # animation curves and timings
      monitors.nix                # monitor declarations (update connector name)
    waybar/
      default.nix                 # module layout + config
      style.css                   # floating pill CSS, glassmorphism
    rofi/
      default.nix                 # launcher config
      style.rasi                  # glass launcher CSS
    hyprlock/
      default.nix                 # lock screen (matugen-integrated colors)
    matugen/
      templates/                  # per-app color templates
      rofi-wallpaper.sh           # wallpaper picker script for rofi
    swww/
      default.nix                 # swww daemon autostart
    git.nix                       # git identity, delta diffs, ssh, gpg
    terminal.nix                  # kitty, fish, tide prompt, fzf, zoxide, atuin
    theme.nix                     # GTK/Qt, cursor, icons
    notifications.nix             # swaync config + matugen-integrated CSS
    nightlight.nix                # wlsunset blue light filter
    apps.nix                      # Chrome, VSCodium, hyprpicker, utilities
    gaming.nix                    # Heroic, ProtonUp-Qt, MangoHud config
    filemanager.nix               # Thunar + MIME type associations
    clipboard.nix                 # wl-clipboard + cliphist history
    screenshot.nix                # grimblast + satty annotation
    matugen.nix                   # matugen config, templates, activation hook

home/
  jkoch/
    default.nix                   # imports all home modules for this user

wallpapers/                       # wallpaper images; default.jpg used on first boot
scripts/
  change-wallpaper.sh             # swww + matugen + component reload pipeline
```

---

## License

MIT — see [LICENSE](LICENSE).

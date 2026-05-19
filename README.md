# nix-rice

A daily-driver NixOS + Hyprland desktop built for stability, rollback safety, and a glassmorphism aesthetic where every color is derived from your wallpaper via Google's Material You algorithm.

**Hardware target:** NVIDIA RTX 3070 · Ryzen 5 5600X · 2560×1440@240Hz GSync

---

## Stack

| Layer | Choice |
|---|---|
| OS | NixOS (unstable channel, flakes) |
| Compositor | Hyprland + UWSM session management |
| Shell / bar | Quickshell — end-4 illogical-impulse foundation, debloated via Nix |
| Launcher / overview | Quickshell overview — app search, clipboard prefix, workspace previews |
| Control center | Quickshell SidebarRight — sliders, WiFi, Bluetooth, notifications, calendar |
| Terminal | Foot + Fish + Starship prompt |
| Notifications | Quickshell notifications |
| Lock screen | Quickshell lock |
| Wallpaper daemon | Quickshell background service + wallpaper selector |
| Color engine | matugen (Material You from wallpaper) |
| GTK theme | adw-gtk3-dark + Papirus-Dark + Bibata-Modern-Ice cursor |
| Night light | hyprsunset through Quickshell |
| Gaming | Steam · Gamemode · Gamescope · MangoHud · Heroic · Lutris · PrismLauncher |
| Apps | Google Chrome · VSCodium · Dolphin · mpv · imv |
| Notes | Obsidian |
| AI | Quickshell SidebarLeft with Claude via OpenRouter and native Anthropic overlay |
| Music | Sidra — Apple Music client with lossless DRM streaming + MPRIS |
| Music widget | Quickshell media controls overlay |
| Power menu | Quickshell session screen |
| Secrets / SSH agent | GNOME Keyring — unlocked at login, backs Chrome passwords + SSH keys |
| Qt theming | Kvantum — Qt apps match the glassmorphism aesthetic |
| Screen recording | OBS Studio (v4l2loopback virtual camera included) |
| Printing | CUPS + Avahi — auto-discovers network/AirPrint printers |
| Password manager | Bitwarden |
| PDF viewer | Zathura — keyboard-driven, dark-themed |
| Disk management | GNOME Disks — partition, format, SMART health |

---

## How the color pipeline works

Every color on the desktop — window borders, Quickshell, GTK, Qt, and Hyprland — is derived from a single wallpaper image at runtime. Changing the wallpaper recolors the shell and apps through matugen.

```
wallpaper image
    │
    ▼
matugen (Google's Material You algorithm)
    │  generates a tonal palette from dominant hues
    ▼
per-app color files written to ~/.cache/matugen/
    ├── hyprland-colors.conf   ← window border gradient (primary + tertiary)
    ├── gtk-colors.css
    ├── Kvantum/MatugenGlass/MatugenGlass.kvconfig
    └── ~/.local/state/quickshell/user/generated/colors.json
    │
    ▼
Quickshell wallpaper selector/background service triggers matugen,
then Quickshell and Hyprland consume the generated colors.
```

On first login, before you've ever set a wallpaper, stub color files are written automatically so nothing crashes.

---

## Prerequisites

- NixOS installed (any recent version — the config will switch to unstable)
- Git
- A dark wallpaper image (`.jpg` or `.png`)
- NVIDIA GPU (RTX series) — other GPUs need changes, see [Non-NVIDIA GPUs](#non-nvidia-gpus)

---

## Installation

### Step 0 — Download NixOS

Use the **minimal ISO** (not the desktop/GNOME ISO).

> **Why minimal?** This config installs its own Hyprland desktop from scratch. The desktop ISO ships GNOME, which you'll never use — it adds ~1 GB of packages that get replaced immediately. The minimal ISO boots straight to a TTY where you run the installer.

Download from **nixos.org/download** → scroll to *NixOS: the Linux distribution* → pick **Minimal ISO image** for x86_64.

After flashing to a USB (`dd`, Rufus, Etcher, etc.) and booting, you'll land at a root shell prompt. Continue below.

### Step 1 — Clone the repo

```bash
sudo git clone https://github.com/SupremeTitan48/personal-nix-rice /etc/nixos
cd /etc/nixos
```

### Step 2 — Run the installer

```bash
sudo bash install.sh
```

The installer will ask you:

| Prompt | Example |
|---|---|
| Linux username | `alice` |
| Full name (for git) | `Alice Smith` |
| Email (for git) | `alice@example.com` |
| Timezone | `Europe/London` |
| Latitude / Longitude | `51.5` / `-0.1` |
| Monitor string | `DP-1,2560x1440@240,0x0,1` |
| NVIDIA open kernel module | `true` (RTX 30xx+) or `false` (older) |
| GitHub repo URL for auto-upgrade | `github:yourusername/personal-nix-rice` |

It then:
1. Writes your answers to `user-config.nix`
2. Generates `hosts/desktop/hardware.nix` for your machine
3. Creates `~/wallpapers/` and reminds you to add a wallpaper
4. Pins all flake inputs in `flake.lock`
5. Runs `nixos-rebuild switch` to activate everything

### Step 3 — Add a wallpaper

Drop a dark image into `~/wallpapers/default.jpg` before (or just after) the build:

```bash
cp ~/your-wallpaper.jpg ~/wallpapers/default.jpg
```

Dark images produce better glassmorphism results — surface colors are already near-black so contrast ratios work out naturally.

### Step 4 — Log in

Reboot, select **Hyprland** in the SDDM session picker, and log in. On first login matugen generates your color palette from the default wallpaper and reloads all components.

---

## Manual configuration (if not using install.sh)

All personal values live in one file — `user-config.nix` at the repo root. Edit it directly, then rebuild:

```nix
{
  username   = "yourusername";
  gitName    = "Your Name";
  gitEmail   = "you@example.com";
  timezone   = "America/Chicago";
  latitude   = "41.8";
  longitude  = "-87.6";
  monitor    = "DP-1,2560x1440@240,0x0,1";
  nvidiaOpen = true;
  repoUrl    = "github:yourusername/personal-nix-rice";
}
```

You also need to generate hardware config for your machine:

```bash
nixos-generate-config --show-hardware-config | sudo tee hosts/desktop/hardware.nix
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

---

## CI / CD

### Continuous integration (GitHub Actions)

Every push and pull request to `main` runs `.github/workflows/check.yml`, which builds the full NixOS closure (`nix build --no-link`) using the Hyprland Cachix binary cache for substitution — no compilation happens in CI.

Broken configs are blocked from reaching `main` before they can affect a live system.

### Continuous deployment (auto-upgrade)

When `repoUrl` is set in `user-config.nix`, a systemd timer on the live machine pulls from GitHub every hour and runs `nixos-rebuild switch` automatically. A failed build never breaks the running system — NixOS only switches atomically on success, and always keeps previous generations for rollback.

The CD flow:
```
push to main → CI validates → systemd timer fires (within 1 hour) → live system rebuilds
```

To disable auto-upgrade, set `repoUrl = ""` in `user-config.nix`.

---

## Verify your monitor connector

The monitor string defaults to `DP-1`. After first boot, check your actual connector:

```bash
# From a TTY or SSH:
wlr-randr

# Or from within Hyprland:
hyprctl monitors
```

If your connector is different (e.g. `HDMI-A-1`), update `monitor` in `user-config.nix` and rebuild:

```bash
# Edit user-config.nix, then:
nrs
```

To add a second monitor, edit `modules/home/hyprland/monitors.nix` and add another line to the list:

```nix
wayland.windowManager.hyprland.settings.monitor = [
  userConfig.monitor
  "HDMI-A-1,1920x1080@60,2560x0,1"   # positioned to the right
];
```

---

## Non-NVIDIA GPUs

The config assumes NVIDIA. For AMD or Intel:

1. Remove `../../modules/nixos/nvidia.nix` from `hosts/desktop/default.nix` imports
2. In `modules/home/apps.nix`, change mpv's `hwdec=nvdec` → `hwdec=auto`
3. In `modules/home/hyprland/default.nix`, remove the `cursor.no_hardware_cursors` workaround and the NVIDIA env vars
4. In `modules/nixos/boot.nix`, remove the `nvidia-drm.modeset=1` kernel params
5. In `home/user/default.nix`, remove the NVIDIA entries from `uwsm/env-hyprland`

---

## Keybinds

### Applications

| Key | Action |
|---|---|
| `Super + Return` | Terminal (foot) |
| `Super + Space` | Quickshell search / launcher |
| `Super + Tab` | Quickshell workspace overview |
| `Super + E` | File manager (Dolphin) |
| `Super + M` | Apple Music (Sidra) |
| `Super + Shift + M` | Quickshell media controls |
| `Super + W` | Quickshell wallpaper picker |
| `Super + N` | Quickshell right sidebar / control center |
| `Super + A` | Quickshell left sidebar / Claude chat |
| `Super + /` | Quickshell cheatsheet |

### Power

| Key | Action |
|---|---|
| `Super + Escape` | Quickshell session screen |
| `Super + Ctrl + L` | Quickshell lock screen immediately |

### Windows

| Key | Action |
|---|---|
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Alt + Space` | Toggle floating |
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

### Scratchpads (toggle over any workspace)

| Key | Action |
|---|---|
| `Super + Alt + T` | Terminal scratchpad (foot, pre-spawned) |
| `Super + Alt + O` | Obsidian notes scratchpad |
| `Super + Alt + M` | System monitor scratchpad (Mission Center) |

### System

| Key | Action |
|---|---|
| `Super + V` | Quickshell clipboard overview |
| `Super + .` | Quickshell emoji overview |
| `Print` | Screenshot active monitor → clipboard |
| `Ctrl + Print` | Screenshot active monitor → file + clipboard |
| `Super + Shift + S` | Quickshell region screenshot |
| `Super + Shift + R` | Quickshell region recording |

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

`Super + W` opens the Quickshell wallpaper selector. Selecting one:
1. Updates the Quickshell background
2. Runs matugen to generate a new color palette
3. Refreshes Quickshell and Hyprland colors

Total time: ~1 second.

### From the terminal

To add an image to the picker:

```bash
cp ~/Pictures/some-image.jpg ~/wallpapers/
```

---

## Updating

```bash
cd /etc/nixos
sudo nix flake update    # bump all inputs (Hyprland, nixpkgs, etc.)
nrs                      # alias: sudo nixos-rebuild switch --flake .#desktop
```

To update only one input:

```bash
sudo nix flake update hyprland
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

### All personal settings

Edit `user-config.nix` at the repo root — this is the only file you need to touch for personal preferences. Rebuild after any change: `nrs`

### Gaps, borders, rounding

`modules/home/hyprland/default.nix`:

```nix
general = {
  gaps_in = 6;
  gaps_out = 12;
  border_size = 2;
};
decoration = {
  rounding = 12;
  rounding_power = 4;  # squircle shape (requires Hyprland >= v0.42)
};
```

### Animations

`modules/home/hyprland/animations.nix` — timing curves and durations.

### Quickshell configuration

`modules/home/quickshell/config.nix` — debloated illogical-impulse preset, Claude models, bar behavior, sidebar modules.

### Adding packages

- System-wide: `hosts/desktop/default.nix` → `environment.systemPackages`
- User packages: `home/user/default.nix` → `home.packages`

---

## Troubleshooting

### Black screen after login

Drop to a TTY (`Ctrl+Alt+F2`) and check:

```bash
journalctl -b -u display-manager
hyprctl instances
```

Common fixes:
- Verify `hardware.nvidia.modesetting.enable = true` in `modules/nixos/nvidia.nix`
- Verify `nvidia-drm.modeset=1` is in `boot.kernelParams` in `modules/nixos/boot.nix`
- Toggle `nvidiaOpen` in `user-config.nix` between `true` and `false` and rebuild

### Cursor invisible or flickering

NVIDIA software cursor quirk. In `modules/home/hyprland/default.nix`:

```nix
cursor = {
  no_hardware_cursors = true;
  use_cpu_buffer = true;
};
```

Both should already be set. Also verify `XCURSOR_THEME` and `XCURSOR_SIZE` are in `~/.config/uwsm/env-hyprland`.

### Quickshell not loading / blank shell

```bash
qs -c ii   # run manually to see errors
journalctl --user -u quickshell
```

Usually this is a missing Qt/QML runtime dependency, a bad `config.json`, or missing generated colors. Check `~/.local/state/quickshell/user/generated/colors.json` exists. If not, run `matugen image ~/wallpapers/default.jpg --mode dark`.

### Screen sharing not working

```bash
systemctl --user status xdg-desktop-portal-hyprland
systemctl --user status xdg-desktop-portal-gtk
```

If either is failed: `systemctl --user restart xdg-desktop-portal`

### Colors not updating after wallpaper change

```bash
which matugen
matugen image ~/wallpapers/default.jpg --mode dark
ls ~/.cache/matugen/
ls ~/.local/state/quickshell/user/generated/
```

### Audio not working

```bash
systemctl --user status pipewire pipewire-pulse wireplumber
pactl info   # should show PipeWire as the server
```

### Auto-upgrade not working

```bash
systemctl status nixos-upgrade.service
journalctl -u nixos-upgrade.service
```

Ensure `repoUrl` in `user-config.nix` is set to a **public** GitHub repo. Private repos require SSH key configuration on the system.

---

## File structure

```
user-config.nix                   # ← edit this first (username, git, timezone, monitor, etc.)
install.sh                        # interactive first-time setup script
flake.nix                         # flake inputs + NixOS system definition

.github/
  workflows/
    check.yml                     # CI: nix build --no-link (Cachix-substituted) on every push

hosts/
  desktop/
    default.nix                   # host entry — imports all NixOS modules
    hardware.nix                  # auto-generated by install.sh (nixos-generate-config)

modules/
  nixos/                          # system-level NixOS modules
    nvidia.nix                    # open kernel module, modesetting, VAAPI
    boot.nix                      # systemd-boot, kernel params, linuxPackages_latest
    audio.nix                     # PipeWire + WirePlumber, low-latency config
    gaming.nix                    # Steam, Gamemode, Gamescope, MangoHud, sysctl
    portal.nix                    # xdg-desktop-portal (screencasting + file picker)
    display-manager.nix           # SDDM Wayland + sddm-astronaut theme
    auto-upgrade.nix              # hourly CD — pulls from repoUrl and rebuilds
    keyring.nix                   # GNOME Keyring — SSH agent + secret service, PAM unlock
    printing.nix                  # CUPS + Avahi — printing and network printer discovery
    nix.nix                       # Cachix, GC, store optimise, registry pin
    fonts.nix                     # system-wide font packages
    locale.nix                    # timezone (from user-config), locale, keyboard
    network.nix                   # NetworkManager, Bluetooth, systemd-resolved

  home/                           # Home Manager (per-user configuration)
    hyprland/
      default.nix                 # core config, exec-once, NVIDIA env, blur
      keybinds.nix                # all keybind declarations
      rules.nix                   # window rules, workspace assignments
      animations.nix              # animation curves and timings
      monitors.nix                # monitor string (from user-config)
    quickshell/
      default.nix                 # programs.quickshell + systemd service
      package.nix                 # wrapped Quickshell package with Qt deps
      deps.nix                    # illogical-impulse runtime packages
      config.nix                  # debloated illogical-impulse config.json
      dev.nix                     # ~/src/quickshell-ii dev symlink seeding
    matugen/
      templates/                  # per-app color templates
    git.nix                       # git identity (from user-config), delta, ssh, gpg
    terminal.nix                  # foot, fish, starship, fzf, zoxide, atuin
    theme.nix                     # GTK theme, cursor, icons, Kvantum Qt theming
    apps.nix                      # Chrome, VSCodium, OBS, Bitwarden, Sidra, utilities
    gaming.nix                    # Heroic, ProtonUp-Qt, MangoHud config
    filemanager.nix               # Dolphin + MIME type associations
    clipboard.nix                 # wl-clipboard + cliphist history
    screenshot.nix                # grim/slurp/satty/hyprshot runtime deps
    matugen.nix                   # matugen config, templates, activation hook
    scratchpads.nix               # named scratchpads (terminal, Obsidian, monitor)

overlays/
  ii/
    services/
      Ai.qml                      # patched AI service with Anthropic strategy
      ai/AnthropicApiStrategy.qml # native Claude Messages API strategy

home/
  user/
    default.nix                   # Home Manager entry point (username from user-config)

wallpapers/                       # created by install.sh — add your images here
```

---

## License

MIT — see [LICENSE](LICENSE).

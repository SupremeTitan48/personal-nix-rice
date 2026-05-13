# NixOS + Hyprland Rice — Design Spec

**Date:** 2026-05-13
**User:** jkoch
**Hardware:** Ryzen 5 5600X, NVIDIA RTX 3070, 2560×1440@240 (GSync, HDR)
**Status:** Approved for implementation

---

## 1. Goals

- Daily-driver NixOS + Hyprland desktop, optimized for stability and rollback safety
- Glassmorphism aesthetic with Material You color science derived from wallpaper
- Clean, modular config that stays readable months later
- NVIDIA reliability as a hard requirement
- Gaming-capable (Steam, Gamemode, Gamescope)
- Multi-monitor ready from day one (primary 2560×1440@240, expandable)

---

## 2. Repo Architecture

**Pattern:** Option B — modular hosts/modules flake

```
flake.nix
flake.lock

hosts/
  desktop/
    default.nix          # nixosSystem entry point, imports all modules
    hardware.nix         # generated hardware-configuration.nix

modules/
  nixos/
    nvidia.nix           # proprietary drivers, DRM, modesetting, suspend
    gaming.nix           # steam, gamemode, gamescope, mangohud, lutris
    boot.nix             # systemd-boot, kernel params (nvidia-drm.modeset=1)
    audio.nix            # pipewire, wireplumber
    fonts.nix            # system-wide font packages
    locale.nix           # timezone, locale, keyboard
    network.nix          # networkmanager, bluetooth
    portal.nix           # xdg-desktop-portal-hyprland + xdg-desktop-portal-gtk
    display-manager.nix  # SDDM, wayland session
  home/
    hyprland/
      default.nix        # main config, exec-once, env vars, imports below
      keybinds.nix       # all keybind declarations
      rules.nix          # window rules, workspace assignments
      animations.nix     # animation curves and timings
      monitors.nix       # monitor declarations (placeholder: DP-1, 2560x1440@240)
    waybar/
      default.nix        # waybar service + module config
      style.nix          # CSS — floating pill, glassmorphism, matugen vars
    rofi/
      default.nix        # package, config, modi
      style.nix          # CSS — glass launcher, matugen vars
    hyprlock/
      default.nix        # lock screen config
      style.nix          # CSS — glass lock screen, matugen vars
    swww/
      default.nix        # swww daemon autostart, change-wallpaper script
    matugen.nix          # matugen config, template paths, activation hook
    theme.nix            # GTK2/3 via adw-gtk3, GTK4 libadwaita, Qt, cursor, icons
    terminal.nix         # kitty config, font, shell (fish + starship)
    notifications.nix    # swaync config + CSS
    filemanager.nix      # thunar + tumbler + archive plugin
    clipboard.nix        # wl-clipboard + cliphist, keybind hook
    screenshot.nix       # grimblast, keybinds
    apps.nix             # google-chrome, vscodium, misc
    gaming.nix           # user-level: heroic, lutris shortcuts

home/
  jkoch/
    default.nix          # imports all modules/home/* for jkoch

wallpapers/
  default.jpg            # initial wallpaper for first matugen run

scripts/                 # not nix — helper shell scripts
  change-wallpaper.sh    # swww + matugen + reload pipeline

.gitignore
```

---

## 3. Flake Inputs

| Input | Source | Reason |
|---|---|---|
| `nixpkgs` | `nixos-unstable` | Latest Hyprland, NVIDIA drivers, matugen, all components |
| `home-manager` | `follows nixpkgs` | Eliminates nixpkgs version skew |
| `hyprland` | Hyprland official flake | Compositor may lag nixpkgs-unstable by weeks; NVIDIA is sensitive to version |
| `hyprlock` | `follows hyprland` | Must match compositor version |
| `hypridle` | `follows hyprland` | Must match compositor version |

`allowUnfree = true` required at the flake level for Google Chrome and NVIDIA drivers.

---

## 4. Theming Pipeline

The core design decision: all color is derived from the active wallpaper via matugen's Material You algorithm. No hardcoded accent colors anywhere except fallback defaults.

### Color generation flow

```
wallpaper image
      │
      ▼
matugen run
  (uses Google's Material You tonal palette algorithm)
      │
      ▼
outputs per-app color files:
  ~/.cache/matugen/waybar-colors.css
  ~/.cache/matugen/rofi-colors.rasi
  ~/.cache/matugen/hyprlock-colors.conf
  ~/.cache/matugen/hyprland-colors.conf   (border accent)
  ~/.cache/matugen/gtk-colors.css
  ~/.cache/matugen/kitty-colors.conf
```

### Wallpaper change flow

```
change-wallpaper.sh <path>
  1. swww img <path> --transition-type fade --transition-duration 1
  2. matugen image <path>
  3. killall -SIGUSR2 waybar
  4. hyprctl reload
  5. swaync-client --reload-config
  6. pkill -USR1 kitty           (kitty hot-reloads config)
```

Triggered via: `Super+W` → rofi shows wallpapers/ directory → pick one → script fires.
Total recolor time: ~1 second.

### Base palette (wallpaper-independent)

These never change regardless of wallpaper — they are the neutral slate base that makes any accent color work:

| Role | Value | Notes |
|---|---|---|
| Base | `#0d0f14` | Near-black, cool-tinted |
| Surface | `#181c24` | Window backgrounds |
| Overlay | `#242836` | Hover states, raised elements |
| Glass | `rgba(255,255,255,0.08)` | Blur layer on bars/popups |
| Glass border | `rgba(255,255,255,0.12)` | Subtle edge highlight |
| Text primary | `#e8e8f0` | Cool white |
| Text muted | `#9898a8` | Secondary labels |
| Accent | matugen primary | Derived per wallpaper |

### GTK theming approach

GTK3 apps: `adw-gtk3` theme + matugen-generated CSS override via `~/.config/gtk-3.0/gtk.css`
GTK4/libadwaita apps: adwaita dark + color variables injected via `~/.config/gtk-4.0/gtk.css`
Qt apps: `qt5ct`/`qt6ct` with Kvantum, dark base matching surface color
Cursor: `Bibata-Modern-Ice` (neutral, works with any accent)
Icons: `Papirus-Dark` (clean, well-maintained, dark-friendly)

---

## 5. Component Specs

### Waybar — Top Floating Pill

- **Position:** top-center, floating (no anchored edges)
- **Style:** single pill with rounded ends, `border-radius: 30px`, glassmorphism background
- **Blur:** `background: rgba(13,15,20,0.6); backdrop-filter: blur(20px)`
- **Border:** `1px solid rgba(255,255,255,0.12)` + subtle inner glow from accent
- **Layout (left → right):**
  - Left: Hyprland workspaces (dots, active highlighted with accent)
  - Center: Clock (`%H:%M`, clean, no seconds)
  - Right: System tray, CPU%, GPU temp, volume, network, battery (if laptop added later)
- **Alternate style:** Three separate pills (workspaces | clock | tray) — can be toggled via config flag

### Rofi — Glass Launcher

- **Mode:** `drun` (app launcher) + `run` (command) + custom `wallpaper` modi
- **Style:** centered floating panel, same glass treatment as waybar
- **Input field:** rounded, glass background, accent-colored cursor
- **List items:** subtle hover highlight using accent at 15% opacity
- **Claude integration:** post-baseline — custom `claude` modi that pipes input to Claude API via shell script, shows response in rofi list. Noted for Phase 2.

### Hyprland

- **Border:** `2px`, rounded corners `rounding = 12`, accent color from matugen
- **Inactive border:** `rgba(255,255,255,0.1)` — nearly invisible, very macOS-like
- **Gaps:** `gaps_in = 6`, `gaps_out = 12` — enough breathing room to see wallpaper through glass
- **Shadows:** enabled, soft, dark — `shadow_range = 20`, `shadow_color = rgba(0,0,0,0.4)`
- **Blur:** `enabled = true`, `size = 8`, `passes = 2`, `new_optimizations = true`
- **Animations:** smooth, not overdone — `bezier = myBezier, 0.05, 0.9, 0.1, 1.05`, ~250ms windows, ~150ms workspaces

### Kitty Terminal

- **Font:** `JetBrains Mono` (or `Monaspace Neon` for more character — TBD)
- **Font size:** 13pt
- **Background:** `rgba(13,15,20,0.85)` — slightly transparent so wallpaper bleeds through if window is floating
- **Padding:** `window_padding_width 12`
- **Shell:** fish with starship prompt
- **Colors:** matugen-generated kitty color scheme

### swaync — Notifications

- **Style:** glass panel, rounded corners, slides in from top-right
- **Notification center:** accessible via `Super+N`, same glass treatment
- **CSS:** matugen accent for action buttons, neutral glass for notification bodies

### Hyprlock

- **Background:** blurred wallpaper (full screen, heavy blur `sigma=20`)
- **Clock:** large, centered, bold
- **Input field:** glass pill, centered below clock
- **Style:** minimal — no excessive widgets, just clock + password field

### swww

- **Transition:** `fade`, duration `1.0s` on wallpaper change
- **Daemon:** autostarted in Hyprland `exec-once`
- **Integration:** `change-wallpaper.sh` wraps all matugen + reload logic

---

## 6. NixOS System Modules

### nvidia.nix

```nix
hardware.nvidia = {
  modesetting.enable = true;          # required for Wayland
  powerManagement.enable = true;
  powerManagement.finegrained = false;
  open = false;                        # proprietary, not nvidia-open
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};
services.xserver.videoDrivers = [ "nvidia" ];
```

### boot.nix

- Bootloader: `systemd-boot` (simpler than GRUB, faster, NixOS native)
- Kernel params: `nvidia-drm.modeset=1` (required), `nvidia.NVreg_PreserveVideoMemoryAllocations=1` (suspend fix)
- Kernel: `linuxPackages_latest` for best NVIDIA Wayland support

### audio.nix

- `services.pipewire.enable = true`
- `services.pipewire.alsa.enable = true`
- `services.pipewire.pulse.enable = true`
- `services.pipewire.wireplumber.enable = true`
- `security.rtkit.enable = true`

### portal.nix

Both portals required — hyprland for screen sharing, GTK for file pickers:
- `xdg-desktop-portal-hyprland` (from hyprland flake)
- `xdg-desktop-portal-gtk`

### display-manager.nix

- `services.displayManager.sddm.enable = true`
- `services.displayManager.sddm.wayland.enable = true`
- Theme: `sddm-chili` or plain SDDM (can be riced separately post-baseline)

### gaming.nix

- `programs.steam.enable = true`
- `programs.gamemode.enable = true`
- `programs.gamescope.enable = true`
- `programs.mangohud.enable = true`
- Gamescope NVIDIA note: requires `--backend drm` flag on Wayland

---

## 7. Home Manager Env Vars (Hyprland session)

Set in `modules/home/hyprland/default.nix` via `env = [...]`:

```
LIBVA_DRIVER_NAME = nvidia
XDG_SESSION_TYPE = wayland
GBM_BACKEND = nvidia-drm
__GLX_VENDOR_LIBRARY_NAME = nvidia
NVD_BACKEND = direct
ELECTRON_OZONE_PLATFORM_HINT = auto   # for vscodium, chrome on wayland
MOZ_ENABLE_WAYLAND = 1                # for any firefox usage
QT_QPA_PLATFORM = wayland
```

---

## 8. Keybind Plan (High-Level)

| Keybind | Action |
|---|---|
| `Super+Return` | Launch kitty |
| `Super+Space` | Rofi app launcher |
| `Super+W` | Rofi wallpaper picker → change-wallpaper.sh |
| `Super+N` | swaync notification center toggle |
| `Super+Q` | Close window |
| `Super+F` | Toggle fullscreen |
| `Super+V` | Toggle floating |
| `Super+1..9` | Switch workspace |
| `Super+Shift+1..9` | Move window to workspace |
| `Super+H/J/K/L` | Focus window (vim-style) |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+mouse drag` | Move floating window |
| `Super+right-click drag` | Resize window |
| `Print` | Fullscreen screenshot (grimblast) |
| `Super+Print` | Region screenshot |
| `Super+L` | Lock screen (hyprlock) |
| `Super+V` (hold) | Clipboard history (cliphist → rofi) |

---

## 9. Risk Assessment

| Area | Risk | Mitigation |
|---|---|---|
| NVIDIA + Hyprland | Medium — known to work but can regress on driver updates | Pin nvidia package to `stable`, use `nix-rollback` if needed |
| matugen on first boot | Low — needs an initial wallpaper present | Commit `wallpapers/default.jpg`, run matugen in HM activation |
| HDR | Low-medium — Hyprland HDR is experimental | Disabled by default, toggle via single option |
| GSync on Wayland | Low — works natively in Hyprland without Xorg workarounds | Declare in monitors.nix |
| GTK4/libadwaita theming | Medium — limited by libadwaita's design | adw-gtk3 covers GTK3, accept libadwaita defaults for GTK4 with color injection |
| swww transitions + NVIDIA | Low — swww uses wlr protocols, works well | Test on first boot |
| Screen sharing | Low if portal configured correctly | Both portals required (see portal.nix) |

---

## 10. What is NOT in Scope (Phase 1)

- Rofi Claude API modi (Phase 2)
- SDDM theming/ricing (Phase 2)
- Second monitor configuration (add to monitors.nix when hardware is present)
- Automatic wallpaper rotation / scheduling
- Dotfiles for CLI tools beyond fish/starship (neovim, tmux, etc.)
- Wayland screen recording (wf-recorder — can add later)

---

## 11. Implementation Order (for writing-plans)

1. Repo scaffolding — flake.nix, directory structure, .gitignore
2. NixOS system layer — nvidia, boot, audio, fonts, locale, network, portal, SDDM
3. Home Manager base — flake wiring, home/jkoch/default.nix, basic packages
4. Hyprland — core config, monitors, keybinds, env vars (no theme yet)
5. matugen pipeline — config, templates, change-wallpaper.sh, activation hook
6. Waybar — layout + glass CSS wired to matugen colors
7. Rofi — launcher + wallpaper modi + glass CSS
8. Terminal — kitty + fish + starship + matugen colors
9. Notifications — swaync + CSS
10. Lockscreen — hyprlock + CSS
11. GTK/Qt theming — adw-gtk3, cursors, icons
12. Remaining apps — Chrome, vscodium, thunar, clipboard, screenshots
13. Gaming — steam, gamemode, gamescope, mangohud
14. Polish pass — animation tuning, gap/border tweaks, test wallpaper switching

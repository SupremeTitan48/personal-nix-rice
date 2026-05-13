# NixOS + Hyprland Rice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete, bootable NixOS + Hyprland desktop configuration with glassmorphism theming, matugen wallpaper-derived colors, and NVIDIA RTX 3070 support.

**Architecture:** Modular flake with hosts/modules separation. NixOS system layer handles hardware (NVIDIA, audio, gaming). Home Manager handles all desktop and user config. matugen derives a full Material You palette from the active wallpaper and writes color files that every component imports.

**Tech Stack:** NixOS unstable, Hyprland (own flake), Home Manager, matugen, swww, waybar, rofi-wayland, kitty, fish, swaync, hyprlock, adw-gtk3

**Verification note:** These tasks are written for a NixOS machine. To validate Nix syntax from macOS during authoring, use `nix flake check`. Full evaluation (`nix build .#nixosConfigurations.desktop.config.system.build.toplevel`) requires Linux. Deploy via `nixos-rebuild switch --flake .#desktop` on the target machine.

---

## Task 1: Repo Scaffolding & Flake

**Files:**
- Create: `flake.nix`
- Create: `.gitignore`
- Create: `wallpapers/.gitkeep`
- Create: `scripts/.gitkeep`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p hosts/desktop modules/nixos modules/home/hyprland \
  modules/home/waybar modules/home/rofi modules/home/hyprlock \
  modules/home/swww home/jkoch wallpapers scripts \
  docs/superpowers/plans docs/superpowers/specs
touch wallpapers/.gitkeep scripts/.gitkeep
```

- [ ] **Step 2: Write .gitignore**

```
result
result-*
.direnv
*.swp
.superpowers/
```

- [ ] **Step 3: Write flake.nix**

```nix
{
  description = "jkoch NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprlock, hypridle, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/desktop/default.nix
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          # Provide hyprlock and hypridle HM modules to all users
          home-manager.sharedModules = [
            hyprlock.homeManagerModules.hyprlock
            hypridle.homeManagerModules.hypridle
          ];
          home-manager.users.jkoch = import ./home/jkoch/default.nix;
        }
      ];
    };
  };
}
```

- [ ] **Step 4: Check flake syntax**

```bash
nix flake check
```

Expected: fails with "missing hardware.nix" or similar — that's fine, it proves the flake parses.
If it fails with a Nix parse error, fix the syntax before continuing.

- [ ] **Step 5: Commit**

```bash
git add flake.nix .gitignore wallpapers/.gitkeep scripts/.gitkeep
git commit -m "feat: initialize flake and repo structure"
```

---

## Task 2: Hardware Placeholder & Host Entry

**Files:**
- Create: `hosts/desktop/hardware.nix`
- Create: `hosts/desktop/default.nix`

- [ ] **Step 1: Write hardware.nix placeholder**

This file will be replaced with the output of `nixos-generate-config` at install time. The placeholder lets the flake evaluate now.

```nix
# hosts/desktop/hardware.nix
# REPLACE THIS FILE with the output of: nixos-generate-config --show-hardware-config
# Run that command from the NixOS live ISO after partitioning.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Ryzen 5 5600X — typical kernel modules
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # PLACEHOLDER: set your actual partition UUIDs after running nixos-generate-config
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

- [ ] **Step 2: Write hosts/desktop/default.nix**

```nix
# hosts/desktop/default.nix
{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/portal.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/display-manager.nix
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.jkoch = {
    isNormalUser = true;
    description = "Jackson Koch";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" "input" ];
    shell = pkgs.fish;
  };

  # Allow sudo for wheel group
  security.sudo.wheelNeedsPassword = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "24.11";
}
```

- [ ] **Step 3: Commit**

```bash
git add hosts/
git commit -m "feat: add host entry and hardware placeholder"
```

---

## Task 3: NixOS Boot & NVIDIA

**Files:**
- Create: `modules/nixos/boot.nix`
- Create: `modules/nixos/nvidia.nix`

- [ ] **Step 1: Write modules/nixos/boot.nix**

```nix
# modules/nixos/boot.nix
{ config, pkgs, lib, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel for best NVIDIA Wayland support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Required for NVIDIA Wayland + suspend fix
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
}
```

- [ ] **Step 2: Write modules/nixos/nvidia.nix**

```nix
# modules/nixos/nvidia.nix
{ config, pkgs, lib, ... }:
{
  # Load nvidia kernel module at boot
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;                         # proprietary blob, not nvidia-open
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Required for Wayland + hardware video decode
  hardware.graphics = {
    enable = true;
    enable32Bit = true;                   # for Steam/Wine 32-bit games
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/nixos/boot.nix modules/nixos/nvidia.nix
git commit -m "feat: add boot and nvidia NixOS modules"
```

---

## Task 4: NixOS Audio, Fonts, Locale, Network

**Files:**
- Create: `modules/nixos/audio.nix`
- Create: `modules/nixos/fonts.nix`
- Create: `modules/nixos/locale.nix`
- Create: `modules/nixos/network.nix`

- [ ] **Step 1: Write modules/nixos/audio.nix**

```nix
# modules/nixos/audio.nix
{ config, pkgs, lib, ... }:
{
  # Disable PulseAudio (replaced by PipeWire)
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
```

- [ ] **Step 2: Write modules/nixos/fonts.nix**

```nix
# modules/nixos/fonts.nix
{ config, pkgs, lib, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      inter
      font-awesome
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrains Mono" "Noto Mono" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
```

- [ ] **Step 3: Write modules/nixos/locale.nix**

```nix
# modules/nixos/locale.nix
# PLACEHOLDER: set timeZone to your actual timezone (e.g. "America/New_York", "America/Los_Angeles")
{ config, pkgs, lib, ... }:
{
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.keyMap = "us";
}
```

- [ ] **Step 4: Write modules/nixos/network.nix**

```nix
# modules/nixos/network.nix
# PLACEHOLDER: set hostName to whatever you want (e.g. "nixbox", "desktop")
{ config, pkgs, lib, ... }:
{
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.Policy.AutoEnable = "true";
  };
  services.blueman.enable = true;

  # Open firewall for KDE Connect / local discovery if needed later
  networking.firewall.enable = true;
}
```

- [ ] **Step 5: Commit**

```bash
git add modules/nixos/audio.nix modules/nixos/fonts.nix \
        modules/nixos/locale.nix modules/nixos/network.nix
git commit -m "feat: add audio, fonts, locale, network NixOS modules"
```

---

## Task 5: NixOS Portal & Display Manager

**Files:**
- Create: `modules/nixos/portal.nix`
- Create: `modules/nixos/display-manager.nix`

- [ ] **Step 1: Write modules/nixos/portal.nix**

```nix
# modules/nixos/portal.nix
# xdg-desktop-portal-hyprland is pulled in automatically by hyprland.nixosModules.default.
# We add xdg-desktop-portal-gtk for file pickers used by GTK apps and Chrome.
{ config, pkgs, lib, ... }:
{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = "*";
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };
}
```

- [ ] **Step 2: Write modules/nixos/display-manager.nix**

```nix
# modules/nixos/display-manager.nix
{ config, pkgs, lib, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "";                          # plain SDDM for now; rice separately later
    settings.Theme.CursorTheme = "Bibata-Modern-Ice";
  };

  # Ensure Hyprland is listed as a session option
  programs.hyprland.enable = true;
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/nixos/portal.nix modules/nixos/display-manager.nix
git commit -m "feat: add portal and display manager NixOS modules"
```

---

## Task 6: NixOS Gaming Module

**Files:**
- Create: `modules/nixos/gaming.nix`

- [ ] **Step 1: Write modules/nixos/gaming.nix**

```nix
# modules/nixos/gaming.nix
{ config, pkgs, lib, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # Use system Gamescope for Steam sessions
    gamescopeSession.enable = true;
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
        ioprio = 0;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    lutris
    heroic                              # Epic/GOG launcher
    protonup-qt                         # manage Proton-GE versions
  ];

  # Allow gamemode to adjust process priorities
  security.pam.loginLimits = [
    { domain = "@gamemode"; type = "-"; item = "nice"; value = "-10"; }
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/nixos/gaming.nix
git commit -m "feat: add gaming NixOS module (steam, gamemode, gamescope, mangohud)"
```

---

## Task 7: Home Manager Base Wiring

**Files:**
- Create: `home/jkoch/default.nix`

- [ ] **Step 1: Write home/jkoch/default.nix**

All home modules are imported here. We add them stub-by-stub in subsequent tasks — start with the skeleton so the flake evaluates.

```nix
# home/jkoch/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ../../modules/home/hyprland/default.nix
    ../../modules/home/waybar/default.nix
    ../../modules/home/rofi/default.nix
    ../../modules/home/hyprlock/default.nix
    ../../modules/home/swww/default.nix
    ../../modules/home/matugen.nix
    ../../modules/home/theme.nix
    ../../modules/home/terminal.nix
    ../../modules/home/notifications.nix
    ../../modules/home/filemanager.nix
    ../../modules/home/clipboard.nix
    ../../modules/home/screenshot.nix
    ../../modules/home/apps.nix
    ../../modules/home/gaming.nix
  ];

  home.username = "jkoch";
  home.homeDirectory = "/home/jkoch";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Base packages not covered by specific modules
  home.packages = with pkgs; [
    wget
    curl
    ripgrep
    fd
    eza
    bat
    unzip
    zip
    htop
    pavucontrol
  ];
}
```

- [ ] **Step 2: Create stub files for every imported module so the flake evaluates**

Each stub is a minimal valid Nix file. We fill them in during their own tasks.

```bash
# Run these commands to create stubs
for f in \
  modules/home/waybar/default.nix \
  modules/home/rofi/default.nix \
  modules/home/hyprlock/default.nix \
  modules/home/swww/default.nix \
  modules/home/matugen.nix \
  modules/home/theme.nix \
  modules/home/terminal.nix \
  modules/home/notifications.nix \
  modules/home/filemanager.nix \
  modules/home/clipboard.nix \
  modules/home/screenshot.nix \
  modules/home/apps.nix \
  modules/home/gaming.nix; do
  mkdir -p "$(dirname "$f")"
  echo "{ ... }: { }" > "$f"
done
# Note: waybar/style.css and rofi/style.rasi are CSS/rasi files, not Nix modules.
# They are created in their own tasks (12 and 13). Do NOT create .nix stubs for them.
```

Also create the hyprland directory stubs (default.nix imports sub-files):

```bash
for f in \
  modules/home/hyprland/keybinds.nix \
  modules/home/hyprland/rules.nix \
  modules/home/hyprland/animations.nix \
  modules/home/hyprland/monitors.nix; do
  echo "{ ... }: { }" > "$f"
done
```

- [ ] **Step 3: Check flake evaluates**

```bash
nix flake check
```

Expected: no parse errors. May warn about missing packages — that's fine at this stage.

- [ ] **Step 4: Commit**

```bash
git add home/ modules/home/
git commit -m "feat: add home manager base wiring and module stubs"
```

---

## Task 8: Hyprland Monitors & Core Config

**Files:**
- Modify: `modules/home/hyprland/default.nix` (replace stub)
- Modify: `modules/home/hyprland/monitors.nix` (replace stub)

- [ ] **Step 1: Write modules/home/hyprland/monitors.nix**

```nix
# modules/home/hyprland/monitors.nix
# PLACEHOLDER: replace DP-1 with your actual connector name.
# Find it by running: hyprctl monitors (after first boot) or: wlr-randr
{ ... }:
{
  wayland.windowManager.hyprland.settings.monitor = [
    # name,   resolution@refresh, position, scale
    "DP-1,2560x1440@240,0x0,1"
    # Add more monitors here as needed:
    # "HDMI-A-1,1920x1080@60,2560x0,1"
  ];
}
```

- [ ] **Step 2: Write modules/home/hyprland/default.nix**

```nix
# modules/home/hyprland/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./monitors.nix
    ./keybinds.nix
    ./rules.nix
    ./animations.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      # NVIDIA Wayland env vars — required for RTX 3070
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "MOZ_ENABLE_WAYLAND,1"
        "QT_QPA_PLATFORM,wayland"
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XCURSOR_SIZE,24"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "rgba(5b9cf6ff)";   # overwritten by matugen at login
        "col.inactive_border" = "rgba(ffffff1a)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = "rgba(00000066)";
          color_inactive = "rgba(00000033)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          new_optimizations = true;
          xray = false;
          ignore_opacity = false;
        };
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
        touchpad.natural_scroll = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };

      # Layer blur rules (waybar, rofi, swaync get blur from Hyprland)
      layerrule = [
        "blur, waybar"
        "ignorezero, waybar"
        "blur, rofi"
        "ignorezero, rofi"
        "blur, swaync-notification-window"
        "ignorezero, swaync-notification-window"
        "blur, swaync-control-center"
        "ignorezero, swaync-control-center"
      ];

      # Autostart
      exec-once = [
        "swww-daemon"
        "swww img ${config.home.homeDirectory}/wallpapers/default.jpg --transition-type none"
        "${pkgs.matugen}/bin/matugen image ${config.home.homeDirectory}/wallpapers/default.jpg --mode dark"
        "waybar"
        "swaync"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "hypridle"
      ];

      # Source matugen-generated colors (written on first exec-once above)
      source = [ "~/.cache/matugen/hyprland-colors.conf" ];
    };
  };

  # hypridle config (idle → lock → suspend)
  services.hypridle = {
    enable = true;
    package = inputs.hypridle.packages.${pkgs.stdenv.hostPlatform.system}.hypridle;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
        { timeout = 600; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
      ];
    };
  };

  # Packages needed by exec-once and scripts
  home.packages = with pkgs; [
    swww
    matugen
    polkit_gnome
    wl-clipboard
    cliphist
  ];
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/home/hyprland/
git commit -m "feat: add hyprland core config with NVIDIA env vars and exec-once"
```

---

## Task 9: Hyprland Keybinds, Rules & Animations

**Files:**
- Modify: `modules/home/hyprland/keybinds.nix` (replace stub)
- Modify: `modules/home/hyprland/rules.nix` (replace stub)
- Modify: `modules/home/hyprland/animations.nix` (replace stub)

- [ ] **Step 1: Write modules/home/hyprland/keybinds.nix**

```nix
# modules/home/hyprland/keybinds.nix
{ pkgs, config, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Applications
      "$mod, Return, exec, kitty"
      "$mod, Space, exec, rofi -show drun"
      "$mod, W, exec, rofi -show wallpaper -modi wallpaper:${config.home.homeDirectory}/.local/bin/rofi-wallpaper"
      "$mod, N, exec, swaync-client -t -sw"
      "$mod, E, exec, thunar"

      # Window management
      "$mod, Q, killactive"
      "$mod, F, fullscreen, 0"
      "$mod SHIFT, Space, togglefloating"
      "$mod, P, pseudo"
      "$mod, J, togglesplit"

      # Focus (vim-style)
      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, K, movefocus, u"
      "$mod, J, movefocus, d"

      # Move windows
      "$mod SHIFT, H, movewindow, l"
      "$mod SHIFT, L, movewindow, r"
      "$mod SHIFT, K, movewindow, u"
      "$mod SHIFT, J, movewindow, d"

      # Workspaces
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"

      # Move to workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"

      # Screenshots
      ", Print, exec, grimblast copy output"
      "$mod, Print, exec, grimblast copy area"
      "$mod SHIFT, Print, exec, grimblast save area ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png"

      # Lock screen
      "$mod, L, exec, hyprlock"

      # Clipboard history
      "$mod, V, exec, cliphist list | rofi -dmenu -p '󰅇 Clipboard' | cliphist decode | wl-copy"
    ];

    bindm = [
      # Mouse drag to move/resize floating windows
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindel = [
      # Volume (with repeat)
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    bindl = [
      # Media keys (no repeat)
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
```

- [ ] **Step 2: Write modules/home/hyprland/rules.nix**

```nix
# modules/home/hyprland/rules.nix
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # Float file pickers and dialogs
      "float, class:^(xdg-desktop-portal)(.*)$"
      "float, title:^(Open File)(.*)$"
      "float, title:^(Select a File)(.*)$"
      "float, title:^(Choose wallpaper)(.*)$"
      "float, class:^(blueman-manager)$"
      "float, class:^(pavucontrol)$"

      # Fix Chrome file picker
      "float, class:^(google-chrome)$, title:^(Open Files?)$"

      # Slight transparency for terminals
      "opacity 0.95 0.9, class:^(kitty)$"

      # Gaming: no blur, no rounding for performance
      "noblur, class:^(steam_app_.*)$"
      "noanim, class:^(steam_app_.*)$"
      "immediate, class:^(steam_app_.*)$"

      # Steam main window
      "float, class:^(steam)$, title:^(Steam Settings)$"
      "float, class:^(steam)$, title:^(Friends List)$"

      # Gamescope: fullscreen, no decoration
      "fullscreen, class:^(gamescope)$"
      "noblur, class:^(gamescope)$"
    ];

    workspace = [
      # Assign apps to workspaces (optional — comment out if unwanted)
      # "1, default:true"
      # "2, on-created-empty:kitty"
    ];
  };
}
```

- [ ] **Step 3: Write modules/home/hyprland/animations.nix**

```nix
# modules/home/hyprland/animations.nix
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;

      bezier = [
        "easeOut, 0.05, 0.9, 0.1, 1.05"
        "easeIn, 0.4, 0.0, 0.2, 1"
        "linear, 0.0, 0.0, 1.0, 1.0"
        "overshot, 0.13, 0.99, 0.29, 1.1"
      ];

      animation = [
        "windows, 1, 4, easeOut, slide"
        "windowsOut, 1, 3, easeIn, slide"
        "windowsMove, 1, 3, easeOut"
        "border, 1, 6, default"
        "borderangle, 1, 8, linear, loop"
        "fade, 1, 4, default"
        "workspaces, 1, 3, overshot, slide"
        "specialWorkspace, 1, 3, easeOut, slidevert"
      ];
    };
  };
}
```

- [ ] **Step 4: Commit**

```bash
git add modules/home/hyprland/keybinds.nix \
        modules/home/hyprland/rules.nix \
        modules/home/hyprland/animations.nix
git commit -m "feat: add hyprland keybinds, window rules, and animations"
```

---

## Task 10: matugen Templates & Pipeline

**Files:**
- Modify: `modules/home/matugen.nix` (replace stub)
- Create: `modules/home/matugen/templates/hyprland-colors.conf`
- Create: `modules/home/matugen/templates/waybar-colors.css`
- Create: `modules/home/matugen/templates/rofi-colors.rasi`
- Create: `modules/home/matugen/templates/kitty-colors.conf`
- Create: `modules/home/matugen/templates/gtk-colors.css`

- [ ] **Step 1: Create template directory**

```bash
mkdir -p modules/home/matugen/templates
```

- [ ] **Step 2: Write hyprland colors template**

```
# modules/home/matugen/templates/hyprland-colors.conf
# Generated by matugen — do not edit, changes will be overwritten
$accent       = rgba({{colors.primary.dark.hex_stripped}}ff)
$accent_dim   = rgba({{colors.primary.dark.hex_stripped}}aa)
$surface      = rgba({{colors.surface.dark.hex_stripped}}ff)
```

- [ ] **Step 3: Write waybar colors template**

```css
/* modules/home/matugen/templates/waybar-colors.css */
/* Generated by matugen — do not edit */
@define-color accent         {{colors.primary.dark.hex}};
@define-color accent_container {{colors.primary_container.dark.hex}};
@define-color on_accent      {{colors.on_primary.dark.hex}};
@define-color surface        {{colors.surface.dark.hex}};
@define-color surface_variant {{colors.surface_variant.dark.hex}};
@define-color on_surface     {{colors.on_surface.dark.hex}};
@define-color muted          {{colors.outline.dark.hex}};
@define-color error          {{colors.error.dark.hex}};
```

- [ ] **Step 4: Write rofi colors template**

```css
/* modules/home/matugen/templates/rofi-colors.rasi */
/* Generated by matugen — do not edit */
* {
    accent:          {{colors.primary.dark.hex}};
    accent-dim:      {{colors.primary_container.dark.hex}};
    on-accent:       {{colors.on_primary.dark.hex}};
    surface:         {{colors.surface.dark.hex}};
    surface-variant: {{colors.surface_variant.dark.hex}};
    on-surface:      {{colors.on_surface.dark.hex}};
    muted:           {{colors.outline.dark.hex}};
    error:           {{colors.error.dark.hex}};
}
```

- [ ] **Step 5: Write kitty colors template**

```
# modules/home/matugen/templates/kitty-colors.conf
# Generated by matugen — do not edit
background  {{colors.background.dark.hex}}
foreground  {{colors.on_background.dark.hex}}

selection_background  {{colors.primary.dark.hex}}
selection_foreground  {{colors.on_primary.dark.hex}}

cursor       {{colors.primary.dark.hex}}
cursor_text_color {{colors.on_primary.dark.hex}}

# 16 terminal colors mapped to Material You tones
color0   {{colors.surface.dark.hex}}
color1   {{colors.error.dark.hex}}
color2   {{colors.primary.dark.hex}}
color3   {{colors.tertiary.dark.hex}}
color4   {{colors.secondary.dark.hex}}
color5   {{colors.primary_container.dark.hex}}
color6   {{colors.tertiary_container.dark.hex}}
color7   {{colors.on_surface.dark.hex}}
color8   {{colors.surface_variant.dark.hex}}
color9   {{colors.on_error_container.dark.hex}}
color10  {{colors.inverse_primary.dark.hex}}
color11  {{colors.on_tertiary_container.dark.hex}}
color12  {{colors.on_secondary_container.dark.hex}}
color13  {{colors.secondary.dark.hex}}
color14  {{colors.secondary_container.dark.hex}}
color15  {{colors.on_background.dark.hex}}
```

- [ ] **Step 6: Write gtk colors template**

```css
/* modules/home/matugen/templates/gtk-colors.css */
/* Generated by matugen — do not edit */
/* Imported by ~/.config/gtk-3.0/gtk.css and ~/.config/gtk-4.0/gtk.css */
@define-color accent_color          {{colors.primary.dark.hex}};
@define-color accent_bg_color       {{colors.primary.dark.hex}};
@define-color accent_fg_color       {{colors.on_primary.dark.hex}};
@define-color window_bg_color       {{colors.surface.dark.hex}};
@define-color window_fg_color       {{colors.on_surface.dark.hex}};
@define-color view_bg_color         {{colors.surface_variant.dark.hex}};
@define-color view_fg_color         {{colors.on_surface_variant.dark.hex}};
@define-color headerbar_bg_color    {{colors.surface.dark.hex}};
@define-color headerbar_fg_color    {{colors.on_surface.dark.hex}};
@define-color popover_bg_color      {{colors.surface_variant.dark.hex}};
@define-color card_bg_color         {{colors.surface_variant.dark.hex}};
@define-color card_fg_color         {{colors.on_surface_variant.dark.hex}};
@define-color sidebar_bg_color      {{colors.surface.dark.hex}};
@define-color sidebar_fg_color      {{colors.on_surface.dark.hex}};
```

- [ ] **Step 7: Write modules/home/matugen.nix**

```nix
# modules/home/matugen.nix
{ config, pkgs, lib, ... }:
let
  templateDir = ./matugen/templates;
  cacheDir = "${config.home.homeDirectory}/.cache/matugen";
in
{
  home.packages = [ pkgs.matugen ];

  # matugen config tells it where to find templates and where to write outputs
  xdg.configFile."matugen/config.toml".text = ''
    [config]
    reload_apps_list = []

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/hyprland-colors.conf"
    output_path = "${cacheDir}/hyprland-colors.conf"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/waybar-colors.css"
    output_path = "${cacheDir}/waybar-colors.css"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/rofi-colors.rasi"
    output_path = "${cacheDir}/rofi-colors.rasi"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/kitty-colors.conf"
    output_path = "${cacheDir}/kitty-colors.conf"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/gtk-colors.css"
    output_path = "${cacheDir}/gtk-colors.css"
  '';

  # Deploy templates into ~/.config/matugen/templates/
  xdg.configFile."matugen/templates/hyprland-colors.conf".source =
    "${templateDir}/hyprland-colors.conf";
  xdg.configFile."matugen/templates/waybar-colors.css".source =
    "${templateDir}/waybar-colors.css";
  xdg.configFile."matugen/templates/rofi-colors.rasi".source =
    "${templateDir}/rofi-colors.rasi";
  xdg.configFile."matugen/templates/kitty-colors.conf".source =
    "${templateDir}/kitty-colors.conf";
  xdg.configFile."matugen/templates/gtk-colors.css".source =
    "${templateDir}/gtk-colors.css";

  # Run matugen on first login (generates cache from default wallpaper)
  home.activation.matugenInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALLPAPER="${config.home.homeDirectory}/wallpapers/default.jpg"
    CACHE="${cacheDir}"
    mkdir -p "$CACHE"
    if [ -f "$WALLPAPER" ]; then
      $DRY_RUN_CMD ${pkgs.matugen}/bin/matugen image "$WALLPAPER" --mode dark || true
    fi
  '';
}
```

- [ ] **Step 8: Commit**

```bash
git add modules/home/matugen.nix modules/home/matugen/
git commit -m "feat: add matugen config, templates, and activation hook"
```

---

## Task 11: change-wallpaper.sh & swww Module

**Files:**
- Create: `scripts/change-wallpaper.sh`
- Create: `modules/home/matugen/rofi-wallpaper.sh` (rofi modi script)
- Modify: `modules/home/swww/default.nix` (replace stub)

- [ ] **Step 1: Write scripts/change-wallpaper.sh**

```bash
#!/usr/bin/env bash
# change-wallpaper.sh — set wallpaper, regenerate colors, reload all components
set -euo pipefail

WALLPAPER="${1:?Usage: change-wallpaper <path-to-image>}"
WALLPAPER="$(realpath "$WALLPAPER")"

if [[ ! -f "$WALLPAPER" ]]; then
  echo "Error: file not found: $WALLPAPER" >&2
  exit 1
fi

# 1. Set wallpaper with crossfade transition
swww img "$WALLPAPER" \
  --transition-type fade \
  --transition-duration 1 \
  --transition-fps 60

# 2. Generate Material You palette from the new wallpaper
matugen image "$WALLPAPER" --mode dark

# 3. Reload waybar colors (SIGUSR2 = reload config+CSS without restarting)
pkill -SIGUSR2 waybar 2>/dev/null || true

# 4. Reload hyprland (picks up updated hyprland-colors.conf via source=)
hyprctl reload 2>/dev/null || true

# 5. Reload swaync CSS
swaync-client --reload-config 2>/dev/null || true

# 6. Reload kitty (USR1 = hot-reload config in all running kitty instances)
pkill -USR1 kitty 2>/dev/null || true

echo "Wallpaper changed and colors reloaded."
```

```bash
chmod +x scripts/change-wallpaper.sh
```

- [ ] **Step 2: Write the rofi wallpaper modi script**

```bash
# modules/home/matugen/rofi-wallpaper.sh
#!/usr/bin/env bash
# Rofi script-mode: lists wallpapers, runs change-wallpaper on selection
WALLPAPER_DIR="${HOME}/wallpapers"

if [[ -z "${ROFI_RETV:-}" ]]; then
  # First call: list available wallpapers
  find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) \
    | sort \
    | xargs -I{} basename {}
else
  # Second call: user selected an entry
  SELECTED="${1}"
  FULL_PATH="${WALLPAPER_DIR}/${SELECTED}"
  "${HOME}/.local/bin/change-wallpaper" "$FULL_PATH" &
fi
```

- [ ] **Step 3: Write modules/home/swww/default.nix**

```nix
# modules/home/swww/default.nix
# swww handles wallpaper display and crossfade transitions.
# The actual wallpaper set + matugen pipeline lives in change-wallpaper.sh.
{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.swww ];

  # Install change-wallpaper as a user binary
  home.file.".local/bin/change-wallpaper" = {
    source = ../../../scripts/change-wallpaper.sh;
    executable = true;
  };

  # Install rofi wallpaper modi script
  home.file.".local/bin/rofi-wallpaper" = {
    source = ../matugen/rofi-wallpaper.sh;
    executable = true;
  };
}
```

- [ ] **Step 4: Make rofi-wallpaper.sh executable in source**

```bash
chmod +x modules/home/matugen/rofi-wallpaper.sh
```

- [ ] **Step 5: Commit**

```bash
git add scripts/change-wallpaper.sh modules/home/matugen/rofi-wallpaper.sh \
        modules/home/swww/default.nix
git commit -m "feat: add swww module, change-wallpaper script, rofi wallpaper modi"
```

---

## Task 12: Waybar Config & CSS

**Files:**
- Modify: `modules/home/waybar/default.nix` (replace stub)
- Modify: `modules/home/waybar/style.nix` (replace stub — used as CSS file source)

- [ ] **Step 1: Write modules/home/waybar/default.nix**

```nix
# modules/home/waybar/default.nix
{ config, pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = [{
      layer = "top";
      position = "top";
      height = 36;
      margin-top = 8;
      margin-left = 180;
      margin-right = 180;
      margin-bottom = 0;
      exclusive = true;
      passthrough = false;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "cpu" "temperature" "pulseaudio" "network" "tray" ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "●";
          "2" = "●";
          "3" = "●";
          "4" = "●";
          "5" = "●";
          default = "○";
          active = "●";
          empty = "○";
        };
        on-click = "activate";
        sort-by-number = true;
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
        };
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %B %d %Y  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = " {usage}%";
        interval = 2;
        tooltip = false;
      };

      temperature = {
        format = " {temperatureC}°C";
        hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
        input-filename = "temp1_input";
        critical-threshold = 80;
        format-critical = " {temperatureC}°C";
        interval = 5;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 Muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "pavucontrol";
        scroll-step = 5;
      };

      network = {
        format-wifi = " {signalStrength}%";
        format-ethernet = "󰈀 {ipaddr}";
        format-disconnected = "󰤭 Offline";
        tooltip-format-wifi = "{essid} ({signalStrength}%) via {ifname}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
        interval = 5;
      };

      tray = {
        spacing = 8;
        icon-size = 16;
      };
    }];

    # CSS is written separately to leverage matugen's @import
    style = builtins.readFile ./style.css;
  };
}
```

- [ ] **Step 2: Create modules/home/waybar/style.css**

Note: this file is a CSS file, not a Nix file. Create it at `modules/home/waybar/style.css`:

```css
/* modules/home/waybar/style.css */
/* Waybar floating pill — glassmorphism style */
/* Fallbacks defined first; matugen @import overrides them when cache exists.
   GTK CSS processes @import content before the surrounding file's declarations,
   so placing @import AFTER @define-color means the import wins. */

/* Fallback colors (used if matugen cache hasn't been written yet) */
@define-color accent         #5b9cf6;
@define-color accent_container #1a3a6e;
@define-color on_accent      #ffffff;
@define-color surface        #181c24;
@define-color surface_variant #242836;
@define-color on_surface     #e8e8f0;
@define-color muted          #9898a8;
@define-color error          #f28b82;

/* matugen overrides — written by activation hook before first login */
@import "/home/jkoch/.cache/matugen/waybar-colors.css";

* {
  font-family: "JetBrains Mono", "Font Awesome 6 Free", monospace;
  font-size: 13px;
  min-height: 0;
  border: none;
  border-radius: 0;
}

window#waybar {
  background: rgba(13, 15, 20, 0.65);
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 30px;
  color: @on_surface;
  transition: background 0.3s ease;
}

window#waybar.hidden {
  opacity: 0.2;
}

.modules-left,
.modules-center,
.modules-right {
  padding: 0 8px;
}

/* Workspaces */
#workspaces {
  padding: 0 4px;
}

#workspaces button {
  padding: 4px 6px;
  color: @muted;
  background: transparent;
  font-size: 10px;
  transition: color 0.2s ease;
  min-width: 16px;
}

#workspaces button.active {
  color: @accent;
  font-size: 12px;
}

#workspaces button.empty {
  color: rgba(255, 255, 255, 0.2);
}

#workspaces button:hover {
  background: rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  color: @on_surface;
}

/* Clock */
#clock {
  font-weight: 600;
  font-size: 14px;
  color: @on_surface;
  padding: 0 8px;
}

/* Right modules — shared style */
#cpu,
#temperature,
#pulseaudio,
#network,
#tray {
  color: @muted;
  padding: 0 6px;
  transition: color 0.2s ease;
}

#cpu:hover,
#temperature:hover,
#pulseaudio:hover,
#network:hover {
  color: @on_surface;
}

#temperature.critical {
  color: @error;
}

#pulseaudio.muted {
  color: @muted;
}

/* Tray */
#tray > .passive {
  -gtk-icon-effect: dim;
}

#tray > .needs-attention {
  -gtk-icon-effect: highlight;
  background-color: @accent_container;
  border-radius: 8px;
}
```

- [ ] **Step 3: Update default.nix to reference style.css correctly**

The `builtins.readFile` in step 1 references `./style.css` which is the CSS file. Verify this path is correct relative to `modules/home/waybar/default.nix`.

- [ ] **Step 4: Commit**

```bash
git add modules/home/waybar/
git commit -m "feat: add waybar floating pill config and glassmorphism CSS"
```

---

## Task 13: Rofi Config & CSS

**Files:**
- Modify: `modules/home/rofi/default.nix` (replace stub)
- Create: `modules/home/rofi/style.rasi`
- Create: `modules/home/rofi/config.rasi`

- [ ] **Step 1: Write modules/home/rofi/default.nix**

```nix
# modules/home/rofi/default.nix
{ config, pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    extraConfig = {
      modi = "drun,run,wallpaper:${config.home.homeDirectory}/.local/bin/rofi-wallpaper";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun = " Apps";
      display-run = " Run";
      display-wallpaper = " Wallpaper";
      terminal = "kitty";
      font = "JetBrains Mono 12";
    };

    theme = ./style.rasi;
  };
}
```

- [ ] **Step 2: Create modules/home/rofi/style.rasi**

```rasi
/* modules/home/rofi/style.rasi */
/* Glass launcher — inherits matugen colors */

@import "/home/jkoch/.cache/matugen/rofi-colors.rasi"

/* Fallbacks if cache doesn't exist yet */
* {
    accent:          #5b9cf6;
    accent-dim:      #1a3a6e;
    on-accent:       #ffffff;
    surface:         #181c24;
    surface-variant: #242836;
    on-surface:      #e8e8f0;
    muted:           #9898a8;
    error:           #f28b82;

    /* Base settings */
    background-color: transparent;
    text-color:       @on-surface;
    font:             "JetBrains Mono 12";
}

window {
    width:            520px;
    border:           1px solid rgba(255,255,255,0.12);
    border-radius:    16px;
    background-color: rgba(13, 15, 20, 0.75);
    padding:          12px;
}

mainbox {
    background-color: transparent;
    spacing:          8px;
}

inputbar {
    background-color: rgba(255, 255, 255, 0.06);
    border:           1px solid rgba(255,255,255,0.10);
    border-radius:    12px;
    padding:          10px 14px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: transparent;
    text-color:       @accent;
    padding:          0 6px 0 0;
}

entry {
    background-color: transparent;
    text-color:       @on-surface;
    cursor-color:     @accent;
    placeholder:      "Search...";
    placeholder-color: @muted;
}

listview {
    background-color: transparent;
    lines:            8;
    columns:          1;
    spacing:          2px;
    margin:           6px 0 0 0;
}

element {
    background-color: transparent;
    border-radius:    10px;
    padding:          10px 12px;
    orientation:      horizontal;
    spacing:          10px;
}

element.selected {
    background-color: rgba(255,255,255,0.08);
    text-color:       @on-surface;
}

element-icon {
    size:   24px;
    margin: 0 4px 0 0;
}

element-text {
    background-color: transparent;
    text-color:       inherit;
    vertical-align:   0.5;
}

message {
    background-color: transparent;
    padding:          6px 0;
}

textbox {
    text-color:       @muted;
    background-color: transparent;
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/home/rofi/
git commit -m "feat: add rofi glass launcher config and rasi theme"
```

---

## Task 14: Terminal — Kitty, Fish, Starship

**Files:**
- Modify: `modules/home/terminal.nix` (replace stub)

- [ ] **Step 1: Write modules/home/terminal.nix**

```nix
# modules/home/terminal.nix
{ config, pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    font = {
      name = "JetBrains Mono";
      size = 13;
    };

    settings = {
      # Window
      window_padding_width = 12;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;

      # Background transparency — wallpaper bleeds through floating terminal
      background_opacity = "0.85";
      dynamic_background_opacity = "yes";

      # Performance
      repaint_delay = 8;
      sync_to_monitor = "yes";

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";

      # Scrollback
      scrollback_lines = 10000;

      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0";

      # Shell integration
      shell_integration = "enabled";
    };

    # Colors come from matugen — imported at runtime
    extraConfig = ''
      # Include matugen-generated color scheme
      # This file is written by matugen on login and wallpaper change
      include /home/jkoch/.cache/matugen/kitty-colors.conf
    '';
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;

    interactiveShellInit = ''
      # Suppress fish greeting
      set -g fish_greeting ""

      # Initialize starship prompt
      starship init fish | source

      # Better ls/cat with eza and bat
      alias ls 'eza --icons --color=always --group-directories-first'
      alias ll 'eza -la --icons --color=always --group-directories-first'
      alias lt 'eza --tree --icons --color=always --level 2'
      alias cat 'bat --style=auto'

      # Nix shorthand
      alias nrs 'sudo nixos-rebuild switch --flake ~/personal-nix-rice#desktop'
      alias nrt 'sudo nixos-rebuild test --flake ~/personal-nix-rice#desktop'

      # Wallpaper shorthand
      alias wp 'change-wallpaper'
    '';
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;

    settings = {
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      directory = {
        style = "bold blue";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };

      nix_shell = {
        symbol = " ";
        style = "bold cyan";
        format = "[$symbol$state]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "[$duration]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
    };
  };

  home.packages = with pkgs; [
    eza
    bat
    playerctl    # media key support
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/terminal.nix
git commit -m "feat: add kitty + fish + starship terminal config"
```

---

## Task 15: Notifications — swaync

**Files:**
- Modify: `modules/home/notifications.nix` (replace stub)

- [ ] **Step 1: Write modules/home/notifications.nix**

```nix
# modules/home/notifications.nix
{ config, pkgs, lib, ... }:
{
  services.swaync = {
    enable = true;
    package = pkgs.swaynotificationcenter;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 8;
      control-center-margin-left = 0;
      notification-icon-size = 48;
      notification-close-button-size = 24;
      fit-to-screen = false;
      control-center-width = 380;
      control-center-height = 580;
      notification-window-width = 380;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widgets = [ "inhibitors" "title" "dnd" "notifications" ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
      };
    };

    style = ''
      /* swaync glassmorphism CSS */
      /* Accent and surface colors are CSS variables injected by GTK theme */

      * {
        font-family: "JetBrains Mono", sans-serif;
        font-size: 13px;
        transition: all 0.2s ease;
      }

      .control-center {
        background: rgba(13, 15, 20, 0.75);
        border: 1px solid rgba(255, 255, 255, 0.10);
        border-radius: 16px;
        color: #e8e8f0;
        padding: 8px;
      }

      .notification-row {
        outline: none;
        margin-bottom: 4px;
      }

      .notification {
        background: rgba(24, 28, 36, 0.85);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 12px;
        color: #e8e8f0;
      }

      .notification:hover {
        background: rgba(36, 40, 54, 0.9);
      }

      .notification-content {
        background: transparent;
      }

      .notification-default-action {
        background: transparent;
        border-radius: 12px;
      }

      .notification-default-action:hover {
        background: rgba(255, 255, 255, 0.06);
      }

      .notification-action {
        background: rgba(255, 255, 255, 0.06);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 8px;
        color: #e8e8f0;
        margin: 4px 2px 0;
      }

      .notification-action:hover {
        background: rgba(91, 156, 246, 0.25);
        border-color: rgba(91, 156, 246, 0.4);
      }

      .close-button {
        background: rgba(255, 255, 255, 0.06);
        border-radius: 50%;
        color: #9898a8;
        min-height: 24px;
        min-width: 24px;
      }

      .close-button:hover {
        background: rgba(242, 139, 130, 0.3);
        color: #f28b82;
      }

      .widget-title label {
        font-size: 14px;
        font-weight: bold;
        color: #e8e8f0;
      }

      .widget-title button {
        background: rgba(91, 156, 246, 0.2);
        border: 1px solid rgba(91, 156, 246, 0.3);
        border-radius: 8px;
        color: #5b9cf6;
        padding: 4px 10px;
        font-size: 11px;
      }

      .widget-title button:hover {
        background: rgba(91, 156, 246, 0.35);
      }

      .widget-dnd trough {
        background: rgba(255, 255, 255, 0.08);
        border-radius: 12px;
      }

      .widget-dnd trough highlight {
        background: #5b9cf6;
        border-radius: 12px;
      }
    '';
  };
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/notifications.nix
git commit -m "feat: add swaync notifications with glass CSS"
```

---

## Task 16: Lockscreen — hyprlock

**Files:**
- Modify: `modules/home/hyprlock/default.nix` (replace stub)

- [ ] **Step 1: Write modules/home/hyprlock/default.nix**

```nix
# modules/home/hyprlock/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
        grace = 0;
        pam_module = "login";
      };

      background = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/wallpapers/default.jpg";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.5;
          vibrancy = 0.1696;
          contrast = 0.8916;
          noise = 0.0117;
        }
      ];

      # Large clock centered on screen
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b>$(date +"%H:%M")</b>"'';
          color = "rgba(232, 232, 240, 1.0)";
          font_size = 80;
          font_family = "JetBrains Mono Bold";
          shadow_passes = 2;
          shadow_size = 4;
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(date +"%A, %B %d")"'';
          color = "rgba(152, 152, 168, 1.0)";
          font_size = 18;
          font_family = "JetBrains Mono";
          position = "0, 40";
          halign = "center";
          valign = "center";
        }
      ];

      # Glass password input pill
      input-field = [
        {
          monitor = "";
          size = "300, 50";
          outline_thickness = 2;
          dots_size = 0.26;
          dots_spacing = 0.64;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgba(255, 255, 255, 0.15)";
          inner_color = "rgba(13, 15, 20, 0.7)";
          font_color = "rgba(232, 232, 240, 1.0)";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = ''<span foreground="##9898a8">󰌾  Password</span>'';
          hide_input = false;
          rounding = 25;
          check_color = "rgba(91, 156, 246, 1.0)";
          fail_color = "rgba(242, 139, 130, 1.0)";
          fail_text = ''<i>$FAIL <b>($ATTEMPTS)</b></i>'';
          fail_transition = 300;
          capslock_color = "rgba(251, 188, 5, 1.0)";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/hyprlock/
git commit -m "feat: add hyprlock glass lockscreen config"
```

---

## Task 17: GTK/Qt Theming & Apps

**Files:**
- Modify: `modules/home/theme.nix` (replace stub)
- Modify: `modules/home/apps.nix` (replace stub)
- Modify: `modules/home/filemanager.nix` (replace stub)
- Modify: `modules/home/clipboard.nix` (replace stub)
- Modify: `modules/home/screenshot.nix` (replace stub)

- [ ] **Step 1: Write modules/home/theme.nix**

```nix
# modules/home/theme.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    adw-gtk3
    bibata-cursors
    papirus-icon-theme
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
  ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # Inject matugen accent into GTK3 and GTK4
  xdg.configFile."gtk-3.0/gtk.css".text = ''
    @import "/home/jkoch/.cache/matugen/gtk-colors.css";
  '';

  xdg.configFile."gtk-4.0/gtk.css".text = ''
    @import "/home/jkoch/.cache/matugen/gtk-colors.css";
  '';

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum-dark";
  };

  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  # Pointer cursor for X11 fallback (xwayland apps)
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
```

- [ ] **Step 2: Write modules/home/apps.nix**

```nix
# modules/home/apps.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    vscodium

    # VSCodium settings — enable open-vsx extensions marketplace
    (vscodium.override {
      commandLineArgs = [
        "--enable-features=WaylandWindowDecorations"
        "--ozone-platform-hint=auto"
      ];
    })
  ];

  # VSCodium: use open-vsx instead of Microsoft marketplace
  xdg.configFile."VSCodium/product.json".text = builtins.toJSON {
    extensionsGallery = {
      serviceUrl = "https://open-vsx.org/vscode/gallery";
      itemUrl = "https://open-vsx.org/vscode/item";
    };
  };
}
```

- [ ] **Step 3: Write modules/home/filemanager.nix**

```nix
# modules/home/filemanager.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler                 # thumbnail service
    gvfs                         # trash, smb, MTP support
    ffmpegthumbnailer            # video thumbnails
    file-roller                  # archive manager integration
  ];

  # Ensure gvfs and tumbler run as user services
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
    };
  };
}
```

- [ ] **Step 4: Write modules/home/clipboard.nix**

```nix
# modules/home/clipboard.nix
# wl-clipboard provides wl-copy/wl-paste for Wayland clipboard access.
# cliphist stores clipboard history. Both are started in hyprland exec-once.
# The keybind Super+V is in hyprland/keybinds.nix.
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];
}
```

- [ ] **Step 5: Write modules/home/screenshot.nix**

```nix
# modules/home/screenshot.nix
# grimblast is Hyprland's wrapper around grim+slurp for screenshots.
# Keybinds are in hyprland/keybinds.nix:
#   Print          → grimblast copy output   (fullscreen to clipboard)
#   Super+Print    → grimblast copy area     (region to clipboard)
#   Super+Shift+Print → grimblast save area  (region to file)
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    grimblast
    grim
    slurp
  ];

  # Ensure screenshots directory exists
  home.file."Pictures/screenshots/.gitkeep".text = "";
}
```

- [ ] **Step 6: Commit all theme and app modules**

```bash
git add modules/home/theme.nix modules/home/apps.nix \
        modules/home/filemanager.nix modules/home/clipboard.nix \
        modules/home/screenshot.nix
git commit -m "feat: add gtk/qt theme, apps, filemanager, clipboard, screenshot modules"
```

---

## Task 18: Gaming User Module

**Files:**
- Modify: `modules/home/gaming.nix` (replace stub)

- [ ] **Step 1: Write modules/home/gaming.nix**

```nix
# modules/home/gaming.nix
# User-level gaming config. System-level (steam, gamemode) is in modules/nixos/gaming.nix.
{ config, pkgs, lib, ... }:
{
  # protonup-qt for managing Proton-GE versions via GUI
  home.packages = with pkgs; [
    protonup-qt
    heroic
  ];

  # Default Gamescope flags for Wayland + NVIDIA
  # Usage: gamescope -W 2560 -H 1440 -r 240 --backend drm -- %command%
  # Add this to Steam launch options per-game.
  home.file.".config/gamescope-flags".text = ''
    # Paste these into Steam launch options, replacing %command%:
    # gamescope -W 2560 -H 1440 -r 240 --backend drm -- %command%
    #
    # With MangoHud:
    # gamescope -W 2560 -H 1440 -r 240 --backend drm -- mangohud %command%
  '';
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/gaming.nix
git commit -m "feat: add user-level gaming module"
```

---

## Task 19: Add Default Wallpaper

**Files:**
- Create: `wallpapers/default.jpg`

- [ ] **Step 1: Add a dark wallpaper as default**

Download any dark wallpaper you want to use as the initial color seed for matugen. Name it `default.jpg` and place it in the `wallpapers/` directory. A good source for dark minimal wallpapers: https://unsplash.com (search "dark minimal").

For a placeholder that matugen can run on, any dark JPG/PNG will work. The wallpaper can be swapped at any time via `Super+W`.

```bash
# Example: copy an existing dark image
cp /path/to/your/dark-wallpaper.jpg wallpapers/default.jpg
```

- [ ] **Step 2: Remove the gitkeep now that the directory has content**

```bash
git rm wallpapers/.gitkeep
git add wallpapers/default.jpg
git commit -m "feat: add default wallpaper for matugen seed"
```

---

## Task 20: Polish Pass

**Files:**
- Optionally modify: `modules/home/hyprland/animations.nix`
- Optionally modify: `modules/home/waybar/style.css`
- Optionally modify: `modules/home/hyprland/default.nix`

This task is done **on the live NixOS system after first boot and `nixos-rebuild switch`.**

- [ ] **Step 1: Verify NVIDIA Wayland is working**

```bash
# Should show "wayland" not "x11"
echo $XDG_SESSION_TYPE

# Should show the nvidia driver and card
glxinfo | grep "OpenGL renderer"

# Should load without errors
hyprctl monitors
```

- [ ] **Step 2: Verify monitor declaration matches actual connector**

```bash
# List actual connector names
hyprctl monitors

# If DP-1 doesn't match, update modules/home/hyprland/monitors.nix
# with the correct connector name, then rebuild:
sudo nixos-rebuild switch --flake ~/personal-nix-rice#desktop
```

- [ ] **Step 3: Test wallpaper change pipeline**

```bash
# Add a second wallpaper to test color switching
cp /path/to/colorful-wallpaper.jpg ~/wallpapers/test.jpg

# Run the change script
change-wallpaper ~/wallpapers/test.jpg

# Verify: waybar, window borders, and rofi should recolor within 1 second
```

- [ ] **Step 4: Tune animation speed if too slow or too fast**

In `modules/home/hyprland/animations.nix`, adjust the numbers in the `animation` list:
- The third number is speed (lower = faster). Current values: windows=4, workspaces=3.
- Reduce to 3/2 for snappier feel. Increase to 5/4 for more cinematic feel.

After editing, rebuild and test:
```bash
sudo nixos-rebuild switch --flake ~/personal-nix-rice#desktop
```

- [ ] **Step 5: Tune waybar pill margins for your monitor**

In `modules/home/waybar/default.nix`, adjust `margin-left` and `margin-right` values.
At 2560px wide, `180` on each side makes the pill ~64% of screen width.
Increase margins for a shorter pill, decrease for a longer one.

- [ ] **Step 6: Tune blur intensity if too heavy or too light**

In `modules/home/hyprland/default.nix` under `blur`:
- `size`: blur radius (4 = subtle, 12 = heavy). Current: 8.
- `passes`: blur quality (1 = fast/lower quality, 3 = slow/high quality). Current: 2.

- [ ] **Step 7: Final commit**

```bash
git add -A
git commit -m "polish: tune animations, margins, and blur after first boot testing"
```

---

## Deployment Checklist

Run these steps on the target machine after cloning the repo:

```bash
# 1. Clone the repo
git clone https://github.com/jkoch/personal-nix-rice ~/personal-nix-rice
cd ~/personal-nix-rice

# 2. Replace hardware.nix with generated hardware config
nixos-generate-config --show-hardware-config > hosts/desktop/hardware.nix

# 3. Update locale.nix timezone if needed
# Edit modules/nixos/locale.nix

# 4. Update network.nix hostname if desired
# Edit modules/nixos/network.nix

# 5. Add your default wallpaper
cp /path/to/wallpaper.jpg wallpapers/default.jpg

# 6. Build and switch
sudo nixos-rebuild switch --flake .#desktop

# 7. Log out and back in via SDDM → Hyprland session
```

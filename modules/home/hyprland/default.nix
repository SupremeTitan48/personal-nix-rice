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
    plugins = [ ];
    xwayland.enable = true;
    systemd.enable = false;  # UWSM manages the systemd session instead

    settings = {
      # NVIDIA Wayland env vars moved to ~/.config/uwsm/env-hyprland
      # so they propagate to D-Bus activated services. See home/user/default.nix.
      env = [];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "$accent $accent_secondary 45deg";
        "col.inactive_border" = "rgba(ffffff1a)";
        resize_on_border = true;
        allow_tearing = true;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        rounding_power = 4;
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = "rgba(00000066)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          xray = true;  # wallpaper bleed-through for glassmorphism
          ignore_opacity = false;
        };
      };

      cursor = {
        no_hardware_cursors = true;
        use_cpu_buffer = true;
        theme = "Bibata-Modern-Ice";
        size = 24;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
        touchpad.natural_scroll = false;
      };

      group = {
        "col.border_active" = "$accent";
        "col.border_inactive" = "$accent_dim";
        groupbar = {
          font_size = 11;
          font_family = "JetBrains Mono";
          "col.active" = "$accent";
          "col.inactive" = "$surface";
          text_color = "$on_surface";
        };
      };

      dwindle = {
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        vrr = 2;  # fullscreen-only VRR — safer with NVIDIA multi-monitor setups
        animate_mouse_windowdragging = false;
        animate_manual_resizes = false;
      };

      # Layer blur rules (waybar, rofi, swaync, dock, wlogout get blur from Hyprland)
      layerrule = [
        "blur, waybar"
        "ignorezero, waybar"
        "blur, rofi"
        "ignorezero, rofi"
        "blur, swaync-notification-window"
        "ignorezero, swaync-notification-window"
        "blur, swaync-control-center"
        "ignorezero, swaync-control-center"
        "blur, gtk-layer-shell"      # nwg-dock
        "ignorezero, gtk-layer-shell"
        "blur, wlogout"
        "ignorezero, wlogout"
        "blur, eww-music-popup"
        "ignorezero, eww-music-popup"
      ];

      # Autostart — all exec-once entries live here to avoid list-override conflicts.
      # Home Manager's Hyprland module merges the settings attrset by key, so a
      # second module assigning settings."exec-once" would overwrite this list.
      exec-once = [
        # Core desktop
        "bash -c 'swww-daemon & swww wait-ready && swww img ${config.home.homeDirectory}/wallpapers/default.jpg --transition-type fade --transition-duration 1 --transition-fps 60'"
        "${pkgs.matugen}/bin/matugen image ${config.home.homeDirectory}/wallpapers/default.jpg --mode dark"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.swaynotificationcenter}/bin/swaync"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
        "nm-applet --indicator"
        "blueman-applet"
        "swayosd-server"
        "nwg-dock-hyprland -nolauncher -f -i 28 -mb 2"
        "eww daemon"
        "wl-paste --type text --watch cliphist --max-items 750 store"
        "wl-paste --type image --watch cliphist --max-items 750 store"
        # Scratchpads — pre-spawned silently so first toggle is instant
        "[workspace special:term silent] kitty --class=kitty-scratch"
        "[workspace special:obsidian silent] obsidian"
        "[workspace special:monitor silent] mission-center"
      ];
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    source = ~/.cache/matugen/hyprland-colors.conf

    plugin:hyprexpo {
      columns = 3
      gap_size = 8
      bg_col = rgb(0d0f14)
      workspace_method = first 1
      enable_gesture = true
      gesture_fingers = 3
      gesture_distance = 300
      gesture_positive = true
    }

    # Resize submap
    submap = resize
    binde = , right, resizeactive, 20 0
    binde = , left, resizeactive, -20 0
    binde = , up, resizeactive, 0 -20
    binde = , down, resizeactive, 0 20
    binde = , l, resizeactive, 20 0
    binde = , h, resizeactive, -20 0
    binde = , k, resizeactive, 0 -20
    binde = , j, resizeactive, 0 20
    bind = , escape, submap, reset
    bind = , return, submap, reset
    submap = reset
  '';

  # hypridle config (idle → lock → suspend)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
        { timeout = 600; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
      ];
    };
  };

  # Install helper scripts to ~/.local/bin/
  home.file.".local/bin/keybind-help" = {
    source = ../../../scripts/keybind-help.sh;
    executable = true;
  };
  home.file.".local/bin/toggle-gamemode" = {
    source = ../../../scripts/toggle-gamemode.sh;
    executable = true;
  };
  home.file.".local/bin/toggle-recording" = {
    source = ../../../scripts/toggle-recording.sh;
    executable = true;
  };

  # Packages for exec-once entries
  # Note: swww is in swww/default.nix; wl-clipboard/cliphist in clipboard.nix; matugen in matugen.nix
  home.packages = with pkgs; [
    hyprpolkitagent
    networkmanagerapplet
    blueman
    swayosd
    brightnessctl
    # playerctl lives in terminal.nix (already declared there)
  ];

  xdg.configFile."swayosd/style.css".text = ''
    window {
      background: transparent;
      border: none;
    }

    #osd-window {
      background-color: rgba(13, 15, 20, 0.75);
      border: 1px solid rgba(255, 255, 255, 0.10);
      border-radius: 16px;
      padding: 12px 20px;
    }

    progressbar {
      min-width: 200px;
      min-height: 6px;
    }

    progressbar > trough {
      border-radius: 3px;
      background-color: rgba(255, 255, 255, 0.12);
    }

    progressbar > trough > progress {
      border-radius: 3px;
      background-color: @accent;
    }

    progressbar.full > trough > progress {
      background-color: @error;
    }

    image {
      color: @on_surface;
      padding-right: 12px;
    }

    @import "${config.home.homeDirectory}/.cache/matugen/waybar-colors.css";
  '';
}

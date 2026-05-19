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
      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
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
          range = 30;
          render_power = 3;
          # fufexan/dotfiles value — richer than pure black, softer alpha
          color = "rgba(00000055)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 3;            # was 2 — matches JaKooLit/end-4 quality
          xray = true;           # wallpaper bleed-through for glassmorphism
          ignore_opacity = true; # blur shows through semi-transparent layers (JaKooLit)
          popups = true;         # blur right-click menus and tooltips
          special = true;        # blur special workspace (scratchpad) background
        };
      };

      cursor = {
        no_hardware_cursors = true;
        use_cpu_buffer = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
        touchpad.natural_scroll = false;
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

    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    # Fallback color variables — overridden by the matugen source below.
    # Must be raw Hyprlang strings (toHyprconf omits spaces around = for $ keys,
    # which Hyprlang requires for variable definitions to be recognized).
    $accent = rgba(5b9cf6ff)
    $accent_dim = rgba(5b9cf6aa)
    $accent_secondary = rgba(c792eaff)
    $surface = rgba(181c24ff)
    $on_surface = rgba(e8e8f0ff)

    # Source matugen colors to override the fallbacks above.
    source = ~/.cache/matugen/hyprland-colors.conf

    # Autostart
    exec-once = swww-daemon
    exec-once = bash -c 'swww wait-ready; swww img ${config.home.homeDirectory}/wallpapers/default.png --transition-type fade --transition-duration 1 --transition-fps 60'
    exec-once = ${pkgs.matugen}/bin/matugen image ${config.home.homeDirectory}/wallpapers/default.png --mode dark
    exec-once = ${pkgs.waybar}/bin/waybar
    exec-once = ${pkgs.swaynotificationcenter}/bin/swaync
    exec-once = ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent
    exec-once = blueman-applet
    exec-once = swayosd-server
    exec-once = eww daemon
    exec-once = wl-paste --type text --watch cliphist --max-items 750 store
    exec-once = wl-paste --type image --watch cliphist --max-items 750 store
    exec-once = [workspace special:term silent] kitty --class=kitty-scratch
    exec-once = [workspace special:obsidian silent] obsidian
    exec-once = [workspace special:monitor silent] mission-center
    exec-once = [workspace special:bluetooth silent] kitty --class=kitty-bluetuith bluetuith

    # Layer blur rules.
    # Hyprland 0.47+ format: EFFECT VALUE, match:namespace LAYER_NAMESPACE
    # ignore_alpha replaces ignorezero/ignorealpha
    layerrule = blur true, match:namespace waybar
    layerrule = ignore_alpha 0.01, match:namespace waybar
    layerrule = blur true, match:namespace rofi
    layerrule = ignore_alpha 0.01, match:namespace rofi
    layerrule = blur true, match:namespace swaync-notification-window
    layerrule = ignore_alpha 0.01, match:namespace swaync-notification-window
    layerrule = blur true, match:namespace swaync-control-center
    layerrule = ignore_alpha 0.01, match:namespace swaync-control-center
    layerrule = blur true, match:namespace gtk-layer-shell
    layerrule = ignore_alpha 0.01, match:namespace gtk-layer-shell
    layerrule = blur true, match:namespace eww-music-popup
    layerrule = ignore_alpha 0.01, match:namespace eww-music-popup

    general {
      col.active_border = $accent $accent_secondary 45deg
      col.inactive_border = rgba(ffffff1a)
      gaps_out = 12
    }

    decoration {
      shadow {
        color = $accent_shadow
        color_inactive = rgba(00000033)
      }
    }

    group {
      col.border_active = $accent
      col.border_inactive = $accent_dim
      groupbar {
        font_size = 11
        font_family = JetBrains Mono
        col.active = $accent
        col.inactive = $surface
        text_color = $on_surface
      }
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
    bind = , escape, exec, rm -f /tmp/hypr-submap
    bind = , escape, submap, reset
    bind = , return, exec, rm -f /tmp/hypr-submap
    bind = , return, submap, reset
    submap = reset
  '';

  # hypridle config (idle → lock → suspend)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Wrap in bash so swww repaints the wallpaper after hyprlock exits
        lock_cmd = "pidof hyprlock || bash -c 'hyprlock; swww img ${config.home.homeDirectory}/wallpapers/default.png --transition-type none'";
        before_sleep_cmd = "loginctl lock-session";
        # Re-enable display and repaint wallpaper after waking from suspend
        after_sleep_cmd = "hyprctl dispatch dpms on; swww img ${config.home.homeDirectory}/wallpapers/default.png --transition-type none";
        ignore_dbus_inhibit = false;
      };
      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          # Repaint wallpaper when monitor wakes from DPMS sleep
          on-resume = "hyprctl dispatch dpms on; swww img ${config.home.homeDirectory}/wallpapers/default.png --transition-type none";
        }
      ];
    };
  };

  # Install helper scripts to ~/.local/bin/
  home.file.".local/bin/keybind-help" = {
    source = ../../../scripts/keybind-help.sh;
    executable = true;
  };
  home.file.".local/bin/power-menu" = {
    source = ../../../scripts/power-menu.sh;
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
  home.file.".local/bin/cliphist-rofi" = {
    source = ../../../scripts/cliphist-rofi.sh;
    executable = true;
  };
  home.file.".local/bin/waybar-stats" = {
    source = ../../../scripts/waybar-stats.sh;
    executable = true;
  };
  home.file.".local/bin/usb-eject" = {
    source = ../../../scripts/usb-eject.sh;
    executable = true;
  };
  # Deploy a fallback avatar for hyprlock. force=false means the user's own
  # ~/.face (set via Settings or `cp yourphoto.jpg ~/.face`) takes precedence.
  home.file.".face" = {
    source = ../../../assets/default-face.png;
    force = false;
  };

  # Packages for exec-once entries
  # Note: swww is in swww/default.nix; wl-clipboard/cliphist in clipboard.nix; matugen in matugen.nix
  home.packages = with pkgs; [
    hyprpolkitagent
    networkmanager_dmenu
    blueman
    bluetuith
    swayosd
    brightnessctl
    imagemagick
    # playerctl lives in terminal.nix (already declared there)
  ];

  xdg.configFile."networkmanager-dmenu/config.ini".source =
    ../networkmanager-dmenu.ini;

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

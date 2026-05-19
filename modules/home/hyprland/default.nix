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
    configType = "hyprlang";  # silence HM 26.05 default-change warning (lua is new default)

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
          range = 12;
          render_power = 2;
          color = "rgba(00000044)";
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
    $accent_shadow = rgba(5b9cf622)
    $accent_secondary = rgba(c792eaff)
    $surface = rgba(181c24ff)
    $on_surface = rgba(e8e8f0ff)

    # Source matugen colors to override the fallbacks above.
    source = ~/.cache/matugen/hyprland-colors.conf

    # Autostart
    exec-once = ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent
    exec-once = wl-paste --type text --watch cliphist --max-items 750 store
    exec-once = wl-paste --type image --watch cliphist --max-items 750 store
    exec-once = [workspace special:term silent] foot --app-id=foot-scratch
    exec-once = [workspace special:obsidian silent] obsidian
    exec-once = [workspace special:monitor silent] mission-center

    # Layer blur rules.
    # Hyprland 0.47+ format: EFFECT VALUE, match:namespace LAYER_NAMESPACE
    # ignore_alpha replaces ignorezero/ignorealpha
    layerrule = blur true, match:namespace quickshell
    layerrule = ignore_alpha 0.01, match:namespace quickshell
    layerrule = blur true, match:namespace gtk-layer-shell
    layerrule = ignore_alpha 0.01, match:namespace gtk-layer-shell

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
        lock_cmd = "bash -c 'if pidof qs quickshell >/dev/null; then hyprctl dispatch global quickshell:lock; else hyprlock; fi'";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on; pidof qs quickshell >/dev/null && hyprctl dispatch global quickshell:lockFocus || true";
        ignore_dbus_inhibit = false;
      };
      listener = [
        { timeout = 300; on-timeout = "loginctl lock-session"; }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on; pidof qs quickshell >/dev/null && hyprctl dispatch global quickshell:lockFocus || true";
        }
        { timeout = 900; on-timeout = "systemctl suspend || loginctl suspend"; }
      ];
    };
  };

  # Install helper scripts to ~/.local/bin/
  home.file.".local/bin/toggle-gamemode" = {
    source = ../../../scripts/toggle-gamemode.sh;
    executable = true;
  };
  home.file.".local/bin/toggle-recording" = {
    source = ../../../scripts/toggle-recording.sh;
    executable = true;
  };

  # Packages for exec-once entries
  home.packages = with pkgs; [
    hyprpolkitagent
    hyprlock
    brightnessctl
    imagemagick
    # playerctl lives in terminal.nix (already declared there)
  ];
}

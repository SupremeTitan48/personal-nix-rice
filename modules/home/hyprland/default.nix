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
    systemd.enable = false;  # UWSM manages the systemd session instead

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
        allow_tearing = true;
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
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          xray = false;
          ignore_opacity = false;
        };
      };

      cursor = {
        no_hardware_cursors = true;
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
        "swww-daemon & swww wait-ready && swww img ${config.home.homeDirectory}/wallpapers/default.jpg --transition-type fade --transition-duration 1 --transition-fps 60"
        "${pkgs.matugen}/bin/matugen image ${config.home.homeDirectory}/wallpapers/default.jpg --mode dark"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.swaynotificationcenter}/bin/swaync"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    source = ~/.cache/matugen/hyprland-colors.conf

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

  # polkit_gnome needed for exec-once authentication agent
  # Note: swww is in swww/default.nix; wl-clipboard/cliphist in clipboard.nix; matugen in matugen.nix
  home.packages = [ pkgs.polkit_gnome ];
}

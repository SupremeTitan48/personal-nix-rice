# modules/home/hyprland/keybinds.nix
{ config, ... }:
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
      "$mod, T, togglesplit"

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
      "$mod CTRL, L, exec, hyprlock"

      # Clipboard history
      "$mod, V, exec, cliphist list | rofi -dmenu -p '󰅇 Clipboard' | cliphist decode | wl-copy"

      # Resize submap
      "$mod, R, submap, resize"

      # Special workspace (scratchpad)
      "$mod, grave, togglespecialworkspace, magic"
      "$mod SHIFT, grave, movetoworkspace, special:magic"
    ];

    bindm = [
      # Mouse drag to move/resize floating windows
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindel = [
      # Volume (with repeat) — via swayosd for OSD feedback
      ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
      ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
      # Brightness
      ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
      ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      # Mouse scroll on workspaces
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
    ];

    bindl = [
      # Media keys (no repeat)
      ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
      ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}

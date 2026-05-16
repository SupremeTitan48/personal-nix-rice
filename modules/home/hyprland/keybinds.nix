# modules/home/hyprland/keybinds.nix
{ config, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Applications
      "$mod, Return, exec, kitty"
      "$mod, Space, exec, rofi -show drun -theme ${config.xdg.configHome}/rofi/grid.rasi"
      "$mod, W, exec, rofi -show wallpaper -modi wallpaper:${config.home.homeDirectory}/.local/bin/rofi-wallpaper"
      "$mod, N, exec, swaync-client -t -sw"
      "$mod, E, exec, thunar"
      "$mod, M, exec, sidra"
      "$mod SHIFT, M, exec, eww open --toggle music-popup"
      "$mod, D, exec, nwg-dock-hyprland -d"

      # Power menu
      "$mod, Escape, exec, wlogout -b 5 -c 0 -r 0 -m 2"

      # Keybind cheatsheet
      "$mod, slash, exec, bash ${config.home.homeDirectory}/.local/bin/keybind-help"

      # Window switcher (moved off Alt+Tab so apps receive Alt+Tab natively)
      "$mod SHIFT, Tab, exec, rofi -show window -show-icons"

      # Window management
      "$mod, Q, killactive"
      "$mod, F, fullscreen, 0"
      "$mod SHIFT, Space, togglefloating"
      "$mod, T, layoutmsg, togglesplit"
      "$mod, P, pin"
      "$mod SHIFT, P, pseudo"
      "$mod, C, centerwindow"

      # Groups (tab-style window stacking)
      "$mod, G, togglegroup"
      "$mod SHIFT, G, changegroupactive, f"
      "$mod ALT, G, changegroupactive, b"

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

      # Workspace navigation
      "$mod, Tab, workspace, previous"
      "$mod SHIFT, comma, movecurrentworkspacetomonitor, l"
      "$mod SHIFT, period, movecurrentworkspacetomonitor, r"

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
      ", Print, exec, grimblast --notify save output"
      "$mod, Print, exec, bash -c 'hyprctl notify 0 1500 \"rgb(5b9cf6)\" \"fontsize:12  Select region to annotate\" & grimblast copy area | satty --filename -'"
      "$mod SHIFT, Print, exec, grimblast --notify save area ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png"

      # Lock screen
      "$mod CTRL, L, exec, hyprlock"

      # Utilities
      "$mod SHIFT, C, exec, hyprpicker -a"
      "$mod, V, exec, bash ${config.home.homeDirectory}/.local/bin/cliphist-rofi"

      # Game mode (toggle animations/blur/shadows)
      "$mod, F10, exec, bash ${config.home.homeDirectory}/.local/bin/toggle-gamemode"

      # Screen recording toggle
      "$mod SHIFT, R, exec, bash ${config.home.homeDirectory}/.local/bin/toggle-recording"

      # Resize submap
      "$mod, R, submap, resize"

      # Named scratchpads
      "$mod ALT, T, togglespecialworkspace, term"
      "$mod ALT, O, togglespecialworkspace, obsidian"
      "$mod ALT, M, togglespecialworkspace, monitor"

      # Legacy generic scratchpad
      "$mod ALT, grave, togglespecialworkspace, magic"
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

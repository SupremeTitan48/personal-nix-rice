# modules/home/hyprland/keybinds.nix
{ config, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER

    # Applications
    bind = $mod, Return, exec, kitty
    bind = $mod, Space, exec, rofi -show drun -theme ${config.xdg.configHome}/rofi/grid.rasi
    bind = $mod, W, exec, rofi -show wallpaper -modi wallpaper:${config.home.homeDirectory}/.local/bin/rofi-wallpaper
    bind = $mod, N, exec, swaync-client -t -sw
    bind = $mod, E, exec, thunar
    bind = $mod, M, exec, sidra
    bind = $mod SHIFT, M, exec, eww open --toggle music-popup
    bind = $mod SHIFT, S, exec, eww open --toggle quick-settings-popup
    bind = $mod, D, exec, pkill nwg-dock-hyprland || nwg-dock-hyprland -nolauncher -f -i 28 -mb 2

    # Power menu
    bind = $mod, Escape, exec, wlogout -b 5 -c 0 -r 0 -m 2

    # Keybind cheatsheet
    bind = $mod, slash, exec, bash ${config.home.homeDirectory}/.local/bin/keybind-help

    # Window switcher
    bind = $mod SHIFT, Tab, exec, rofi -show window -show-icons

    # Window management
    bind = $mod, Q, killactive
    bind = $mod, F, fullscreen, 0
    bind = $mod SHIFT, Space, togglefloating
    bind = $mod, T, layoutmsg, togglesplit
    bind = $mod, P, pin
    bind = $mod SHIFT, P, pseudo
    bind = $mod, C, centerwindow

    # Groups (tab-style window stacking)
    bind = $mod, G, togglegroup
    bind = $mod SHIFT, G, changegroupactive, f
    bind = $mod ALT, G, changegroupactive, b

    # Focus (vim-style)
    bind = $mod, H, movefocus, l
    bind = $mod, L, movefocus, r
    bind = $mod, K, movefocus, u
    bind = $mod, J, movefocus, d

    # Move windows
    bind = $mod SHIFT, H, movewindow, l
    bind = $mod SHIFT, L, movewindow, r
    bind = $mod SHIFT, K, movewindow, u
    bind = $mod SHIFT, J, movewindow, d

    # Workspace navigation
    bind = $mod, Tab, workspace, previous
    bind = $mod SHIFT, comma, movecurrentworkspacetomonitor, l
    bind = $mod SHIFT, period, movecurrentworkspacetomonitor, r

    # Workspaces
    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9

    # Move to workspace
    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod SHIFT, 9, movetoworkspace, 9

    # Screenshots
    bind = , Print, exec, grimblast --notify save output
    bind = $mod, Print, exec, bash -c 'hyprctl notify 0 1500 "rgb(5b9cf6)" "fontsize:12  Select region to annotate" & grimblast copy area | satty --filename -'
    bind = $mod SHIFT, Print, exec, grimblast --notify save area ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png

    # Lock screen
    bind = $mod CTRL, L, exec, hyprlock

    # Utilities
    bind = $mod SHIFT, C, exec, hyprpicker -a
    bind = $mod, V, exec, bash ${config.home.homeDirectory}/.local/bin/cliphist-rofi

    # Game mode toggle
    bind = $mod, F10, exec, bash ${config.home.homeDirectory}/.local/bin/toggle-gamemode

    # Screen recording toggle
    bind = $mod SHIFT, R, exec, bash ${config.home.homeDirectory}/.local/bin/toggle-recording

    # Resize submap
    bind = $mod, R, exec, printf resize > /tmp/hypr-submap
    bind = $mod, R, submap, resize

    # Named scratchpads
    bind = $mod ALT, T, togglespecialworkspace, term
    bind = $mod ALT, O, togglespecialworkspace, obsidian
    bind = $mod ALT, M, togglespecialworkspace, monitor

    # Legacy generic scratchpad
    bind = $mod ALT, grave, togglespecialworkspace, magic
    bind = $mod SHIFT, grave, movetoworkspace, special:magic

    # Mouse drag to move/resize floating windows
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    # Volume (with repeat) — via swayosd for OSD feedback
    bindel = , XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise
    bindel = , XF86AudioLowerVolume, exec, swayosd-client --output-volume lower
    # Brightness
    bindel = , XF86MonBrightnessUp, exec, swayosd-client --brightness raise
    bindel = , XF86MonBrightnessDown, exec, swayosd-client --brightness lower
    # Mouse scroll on workspaces
    bindel = $mod, mouse_down, workspace, e+1
    bindel = $mod, mouse_up, workspace, e-1

    # Media keys (no repeat)
    bindl = , XF86AudioMute, exec, swayosd-client --output-volume mute-toggle
    bindl = , XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPrev, exec, playerctl previous
  '';
}

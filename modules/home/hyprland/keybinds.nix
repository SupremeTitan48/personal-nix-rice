# modules/home/hyprland/keybinds.nix
{ config, ... }:
let
  qsIpc = "qs -c ii ipc call";
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER

    # Quickshell surfaces
    bind = $mod, Space, global, quickshell:searchToggleRelease
    bind = $mod, Tab, global, quickshell:overviewWorkspacesToggle
    bind = $mod, V, global, quickshell:overviewClipboardToggle
    bind = $mod, period, global, quickshell:overviewEmojiToggle
    bind = $mod, A, global, quickshell:sidebarLeftToggle
    bind = $mod ALT, A, global, quickshell:sidebarLeftToggleDetach
    bind = $mod, N, global, quickshell:sidebarRightToggle
    bind = $mod, slash, global, quickshell:cheatsheetToggle
    bind = $mod SHIFT, M, global, quickshell:mediaControlsToggle
    bind = $mod, W, global, quickshell:wallpaperSelectorToggle
    bind = $mod SHIFT, W, global, quickshell:wallpaperSelectorRandom
    bind = $mod, Escape, global, quickshell:sessionToggle
    bind = $mod CTRL, L, global, quickshell:lock
    bind = $mod SHIFT, B, global, quickshell:barToggle

    # Applications
    bind = $mod, Return, exec, foot
    bind = $mod, E, exec, dolphin
    bind = $mod, M, exec, sidra

    # Window management
    bind = $mod, Q, killactive
    bind = $mod, F, fullscreen, 0
    bind = $mod ALT, Space, togglefloating
    bind = $mod, D, fullscreen, 1
    bind = $mod, T, layoutmsg, togglesplit
    bind = $mod, P, pin
    bind = $mod SHIFT, P, pseudo
    bind = $mod, C, centerwindow

    # Groups (tab-style window stacking)
    bind = $mod, G, togglegroup
    bind = $mod SHIFT, G, changegroupactive, f
    bind = $mod ALT, G, changegroupactive, b

    # Focus and move windows
    bind = $mod, H, movefocus, l
    bind = $mod, L, movefocus, r
    bind = $mod, K, movefocus, u
    bind = $mod, J, movefocus, d
    bind = $mod SHIFT, H, movewindow, l
    bind = $mod SHIFT, L, movewindow, r
    bind = $mod SHIFT, K, movewindow, u
    bind = $mod SHIFT, J, movewindow, d

    # Workspace navigation
    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9
    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod SHIFT, 9, movetoworkspace, 9
    bind = $mod SHIFT, comma, movecurrentworkspacetomonitor, l
    bind = $mod SHIFT, period, movecurrentworkspacetomonitor, r

    # Screenshots, recording, and utilities via end-4 Quickshell globals.
    bind = $mod SHIFT, S, global, quickshell:regionScreenshot
    bind = $mod SHIFT, A, global, quickshell:regionSearch
    bind = $mod SHIFT, X, global, quickshell:regionOcr
    bind = $mod SHIFT, T, global, quickshell:screenTranslate
    bind = $mod SHIFT, R, global, quickshell:regionRecord
    bind = $mod SHIFT, C, exec, hyprpicker -a
    bind = , Print, exec, grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" - | wl-copy
    bind = CTRL, Print, exec, mkdir -p "$(xdg-user-dir PICTURES)/Screenshots" && grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" "$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date '+%Y-%m-%d_%H.%M.%S').png"

    # Game mode remains a NixOS/gamemode concern outside Quickshell.
    bind = $mod, F10, exec, bash ${config.home.homeDirectory}/.local/bin/toggle-gamemode

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

    # Volume and brightness use end-4's Quickshell IPC, with direct fallbacks.
    bindel = , XF86MonBrightnessUp, exec, ${qsIpc} brightness increment || brightnessctl s 5%+
    bindel = , XF86MonBrightnessDown, exec, ${qsIpc} brightness decrement || brightnessctl s 5%-
    bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5
    bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-
    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle
    bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPrev, exec, playerctl previous

    # Mouse scroll on workspaces
    bindel = $mod, mouse_down, workspace, e+1
    bindel = $mod, mouse_up, workspace, e-1
  '';
}

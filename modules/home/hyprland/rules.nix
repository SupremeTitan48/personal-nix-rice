# modules/home/hyprland/rules.nix
{ ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    # Prevent apps (Steam, Spotify, etc.) from randomly maximizing themselves
    windowrule = suppressevent maximize, class:.*

    # Picture-in-Picture floating
    windowrule = float, title:(Picture-in-Picture)
    windowrule = keepaspectratio, title:(Picture-in-Picture)
    windowrule = pin, title:(Picture-in-Picture)

    # Float file pickers and dialogs
    windowrule = float, class:(xdg-desktop-portal)(.*)
    windowrule = float, title:(Open File)(.*)
    windowrule = float, title:(Select a File)(.*)
    windowrule = float, title:(Choose wallpaper)(.*)
    windowrule = float, class:(blueman-manager)
    windowrule = float, class:(pavucontrol)

    # Fix Chrome file picker
    windowrule = float, class:(google-chrome), title:(Open Files?)

    # Slight transparency for terminals
    windowrule = opacity 0.95 0.9, class:(kitty)

    # Gaming: no blur, no rounding for performance
    windowrule = noblur, class:(steam_app_.*)
    windowrule = noanim, class:(steam_app_.*)
    windowrule = noshadow, class:(steam_app_.*)
    windowrule = norounding, class:(steam_app_.*)
    windowrule = immediate, class:(steam_app_.*)

    # Steam main window
    windowrule = float, class:(steam), title:(Steam Settings)
    windowrule = float, class:(steam), title:(Friends List)

    # Gamescope: fullscreen, no decoration, immediate present
    windowrule = fullscreen, class:(gamescope)
    windowrule = noblur, class:(gamescope)
    windowrule = noshadow, class:(gamescope)
    windowrule = norounding, class:(gamescope)
    windowrule = immediate, class:(gamescope)

    # Idle inhibit for fullscreen windows and games
    windowrule = idleinhibit fullscreen, fullscreen:1
    windowrule = idleinhibit fullscreen, class:(steam_app_.*)
    windowrule = idleinhibit fullscreen, class:(gamescope)

    # wlogout: fullscreen overlay, no animations, no blur bleed
    windowrule = float, class:(wlogout)
    windowrule = fullscreen, class:(wlogout)
    windowrule = noanim, class:(wlogout)

    # Obsidian: slight transparency, treat as normal tiling app
    windowrule = opacity 0.97 0.95, class:(obsidian)

    # Claude desktop
    windowrule = opacity 0.97 0.95, class:(claude)
    windowrule = float, class:(claude), title:(.*Preferences.*)

    # Sidra (Apple Music client)
    windowrule = float, class:(sidra)
    windowrule = center, class:(sidra)
    windowrule = size 60% 70%, class:(sidra)
    windowrule = opacity 0.97 0.93, class:(sidra)

    # nwg-look: float the settings window
    windowrule = float, class:(nwg-look)
    windowrule = center, class:(nwg-look)

    # Mission Center: float when launched as scratchpad
    windowrule = float, class:(io.missioncenter.MissionCenter)

    # Bitwarden: float unlock/password dialogs
    windowrule = float, class:(Bitwarden), title:(.*Bitwarden.*)

    # GNOME Disk Utility
    windowrule = float, class:(gnome-disks)
    windowrule = size 70% 70%, class:(gnome-disks)
    windowrule = center, class:(gnome-disks)

    # OBS Studio: float settings/scene/source dialogs
    windowrule = float, class:(com.obsproject.Studio), title:(.*Properties.*)
    windowrule = float, class:(com.obsproject.Studio), title:(.*Settings.*)
    windowrule = float, class:(com.obsproject.Studio), title:(.*Filters.*)

    # Seahorse (keyring manager)
    windowrule = float, class:(seahorse)
    windowrule = size 60% 65%, class:(seahorse)
    windowrule = center, class:(seahorse)

    # Workspace auto-assign: apps open on their home workspace silently
    windowrule = workspace 2 silent, class:(google-chrome)
    windowrule = workspace 2 silent, class:(chromium)
    windowrule = workspace 2 silent, class:(firefox)
    windowrule = workspace 3 silent, class:(vesktop)
    windowrule = workspace 3 silent, class:(discord)
    windowrule = workspace 5 silent, class:(steam), title:(Steam)

    # Persistent workspaces
    workspace = 1, persistent:true, default:true
    workspace = 2, persistent:true
    workspace = 3, persistent:true
    workspace = 4, persistent:true
    workspace = 5, persistent:true
  '';
}

# modules/home/hyprland/rules.nix
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Float file pickers and dialogs
      "float, class:(xdg-desktop-portal)(.*)"
      "float, title:(Open File)(.*)"
      "float, title:(Select a File)(.*)"
      "float, title:(Choose wallpaper)(.*)"
      "float, class:(blueman-manager)"
      "float, class:(pavucontrol)"

      # Fix Chrome file picker
      "float, class:(google-chrome), title:(Open Files?)"

      # Slight transparency for terminals
      "opacity 0.95 0.9, class:(kitty)"

      # Gaming: no blur, no rounding for performance
      "noblur, class:(steam_app_.*)"
      "noanim, class:(steam_app_.*)"
      "noshadow, class:(steam_app_.*)"
      "norounding, class:(steam_app_.*)"
      "immediate, class:(steam_app_.*)"

      # Steam main window
      "float, class:(steam), title:(Steam Settings)"
      "float, class:(steam), title:(Friends List)"

      # Gamescope: fullscreen, no decoration, immediate present
      "fullscreen, class:(gamescope)"
      "noblur, class:(gamescope)"
      "noshadow, class:(gamescope)"
      "norounding, class:(gamescope)"
      "immediate, class:(gamescope)"

      # Idle inhibit for fullscreen windows and games
      "idleinhibit fullscreen, fullscreen:1"
      "idleinhibit fullscreen, class:(steam_app_.*)"
      "idleinhibit fullscreen, class:(gamescope)"

      # wlogout: fullscreen overlay, no animations, no blur bleed
      "float, class:(wlogout)"
      "fullscreen, class:(wlogout)"
      "noanim, class:(wlogout)"

      # Obsidian: slight transparency, treat as normal tiling app
      "opacity 0.97 0.95, class:(obsidian)"

      # Claude desktop
      "opacity 0.97 0.95, class:(claude)"
      "float, class:(claude), title:(.*Preferences.*)"

      # Sidra (Apple Music client)
      "float, class:(sidra)"
      "center, class:(sidra)"
      "size 60% 70%, class:(sidra)"
      "opacity 0.97 0.93, class:(sidra)"

      # nwg-look: float the settings window
      "float, class:(nwg-look)"
      "center, class:(nwg-look)"

      # Mission Center: float when launched as scratchpad
      "float, class:(io.missioncenter.MissionCenter)"

      # Bitwarden: float unlock/password dialogs
      "float, class:(Bitwarden), title:(.*Bitwarden.*)"

      # GNOME Disk Utility
      "float, class:(gnome-disks)"
      "size 70% 70%, class:(gnome-disks)"
      "center, class:(gnome-disks)"

      # OBS Studio: float settings/scene/source dialogs
      "float, class:(com.obsproject.Studio), title:(.*Properties.*)"
      "float, class:(com.obsproject.Studio), title:(.*Settings.*)"
      "float, class:(com.obsproject.Studio), title:(.*Filters.*)"

      # Seahorse (keyring manager)
      "float, class:(seahorse)"
      "size 60% 65%, class:(seahorse)"
      "center, class:(seahorse)"
    ];

    workspace = [
      "1, persistent:true, default:true"
      "2, persistent:true"
      "3, persistent:true"
      "4, persistent:true"
      "5, persistent:true"
    ];
  };
}

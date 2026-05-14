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

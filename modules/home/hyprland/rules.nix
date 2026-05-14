# modules/home/hyprland/rules.nix
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # Float file pickers and dialogs
      "float, class:^(xdg-desktop-portal)(.*)$"
      "float, title:^(Open File)(.*)$"
      "float, title:^(Select a File)(.*)$"
      "float, title:^(Choose wallpaper)(.*)$"
      "float, class:^(blueman-manager)$"
      "float, class:^(pavucontrol)$"

      # Fix Chrome file picker
      "float, class:^(google-chrome)$, title:^(Open Files?)$"

      # Slight transparency for terminals
      "opacity 0.95 0.9, class:^(kitty)$"

      # Gaming: no blur, no rounding for performance
      "noblur, class:^(steam_app_.*)$"
      "noanim, class:^(steam_app_.*)$"
      "immediate, class:^(steam_app_.*)$"

      # Steam main window
      "float, class:^(steam)$, title:^(Steam Settings)$"
      "float, class:^(steam)$, title:^(Friends List)$"

      # Gamescope: fullscreen, no decoration
      "fullscreen, class:^(gamescope)$"
      "noblur, class:^(gamescope)$"
    ];

  };
}

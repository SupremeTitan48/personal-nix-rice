# modules/home/hyprland/animations.nix
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;

      bezier = [
        "easeOut, 0.05, 0.9, 0.1, 1.05"
        "easeIn, 0.4, 0.0, 0.2, 1"
        "linear, 0.0, 0.0, 1.0, 1.0"
        "overshot, 0.13, 0.99, 0.29, 1.1"
      ];

      animation = [
        "windows, 1, 4, easeOut, slide"
        "windowsOut, 1, 3, easeIn, slide"
        "windowsMove, 1, 3, easeOut"
        "border, 1, 6, default"
        "borderangle, 1, 8, linear, loop"
        "fade, 1, 4, default"
        "workspaces, 1, 3, overshot, slide"
        "specialWorkspace, 1, 3, easeOut, slidevert"
      ];
    };
  };
}

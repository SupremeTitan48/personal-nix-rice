# modules/home/hyprland/animations.nix
{ ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    animations {
      enabled = true

      bezier = easeOut, 0.05, 0.9, 0.1, 1.05
      bezier = easeIn, 0.4, 0.0, 0.2, 1
      bezier = linear, 0.0, 0.0, 1.0, 1.0
      bezier = overshot, 0.13, 0.99, 0.29, 1.1
      bezier = wind, 0.05, 0.9, 0.1, 1.05
      bezier = winOut, 0.3, -0.3, 0, 1

      animation = windows, 1, 5, wind, slide
      animation = windowsOut, 1, 4, winOut, slide
      animation = windowsMove, 1, 3, easeOut
      animation = border, 1, 6, default
      animation = borderangle, 1, 8, linear, loop
      animation = fade, 1, 4, default
      animation = workspaces, 1, 3, overshot, slide
      animation = specialWorkspace, 1, 3, easeOut, slidevert
    }
  '';
}

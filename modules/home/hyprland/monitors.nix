# modules/home/hyprland/monitors.nix
# PLACEHOLDER: replace DP-1 with your actual connector name.
# Find it by running: hyprctl monitors (after first boot) or: wlr-randr
{ ... }:
{
  wayland.windowManager.hyprland.settings.monitor = [
    # name,   resolution@refresh, position, scale
    "DP-1,2560x1440@240,0x0,1"
    # Add more monitors here as needed:
    # "HDMI-A-1,1920x1080@60,2560x0,1"
  ];
}

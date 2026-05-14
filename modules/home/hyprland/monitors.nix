# modules/home/hyprland/monitors.nix
# Monitor string comes from user-config.nix.
# After first boot run `hyprctl monitors` or `wlr-randr` to find your connector,
# then update the monitor field in user-config.nix and rebuild.
{ userConfig, ... }:
{
  wayland.windowManager.hyprland.settings.monitor = [
    # Format: "CONNECTOR,WIDTHxHEIGHT@REFRESH,POSITIONxY,SCALE"
    userConfig.monitor
    # Add more monitors in user-config.nix or directly here:
    # "HDMI-A-1,1920x1080@60,2560x0,1"
  ];
}

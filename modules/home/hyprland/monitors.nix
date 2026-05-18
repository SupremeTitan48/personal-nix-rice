# modules/home/hyprland/monitors.nix
# Monitor string comes from user-config.nix.
# After first boot run `hyprctl monitors` or `wlr-randr` to find your connector,
# then update the monitor field in user-config.nix and rebuild.
{ userConfig, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    monitor = ${userConfig.monitor}
  '';
}

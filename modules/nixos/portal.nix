# modules/nixos/portal.nix
# xdg-desktop-portal-hyprland is pulled in automatically by hyprland.nixosModules.default.
# We add xdg-desktop-portal-gtk for file pickers used by GTK apps and Chrome.
{ config, pkgs, lib, ... }:
{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = "*";
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };
}

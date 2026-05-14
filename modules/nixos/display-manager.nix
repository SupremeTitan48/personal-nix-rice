# modules/nixos/display-manager.nix
{ config, pkgs, lib, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "";                          # plain SDDM for now; rice separately later
    settings.Theme.CursorTheme = "Bibata-Modern-Ice";
  };

  # Ensure Hyprland is listed as a session option
  programs.hyprland.enable = true;

  # Cursor package needed by SDDM
  environment.systemPackages = with pkgs; [ bibata-cursors ];
}

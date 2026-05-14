# modules/nixos/display-manager.nix
{ config, pkgs, lib, inputs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "";                          # plain SDDM for now; rice separately later
    settings.Theme.CursorTheme = "Bibata-Modern-Ice";
  };

  # Hyprland with UWSM session management
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Cursor package needed by SDDM, UWSM for session management
  environment.systemPackages = with pkgs; [ bibata-cursors uwsm ];
}

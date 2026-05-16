# modules/nixos/display-manager.nix
{ config, pkgs, lib, inputs, ... }:
let
  sddmTheme = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
    themeConfig = {
      AccentColor          = "#5b9cf6";
      BackgroundColor      = "#0d0f14";
      FormBackgroundColor  = "#CC181c24";  # Qt AARRGGBB — dark surface at 80%
      HeaderTextColor      = "#e8e8f0";
      TimeTextColor        = "#e8e8f0";
      DateTextColor        = "#9898a8";
      PlaceholderTextColor = "#9898a8";
      LoginFieldTextColor  = "#e8e8f0";
      PasswordFieldTextColor = "#e8e8f0";
      LoginButtonTextColor   = "#ffffff";
      LoginButtonBackgroundColor = "#5b9cf6";
      HighlightTextColor   = "#ffffff";
      HighlightBackgroundColor = "#5b9cf6";
      WarningColor         = "#f28b82";
      Font                 = "JetBrains Mono";
      FontSize             = "12";
      RoundCorners         = "16";
    };
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.sddm;
    extraPackages = [
      pkgs.bibata-cursors
      sddmTheme
    ];
    settings = {
      Theme = {
        CursorTheme = "Bibata-Modern-Ice";
        CursorSize = 24;
      };
    };
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

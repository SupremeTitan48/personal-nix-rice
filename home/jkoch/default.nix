# home/jkoch/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ../../modules/home/hyprland/default.nix
    ../../modules/home/waybar/default.nix
    ../../modules/home/rofi/default.nix
    ../../modules/home/hyprlock/default.nix
    ../../modules/home/swww/default.nix
    ../../modules/home/matugen.nix
    ../../modules/home/theme.nix
    ../../modules/home/terminal.nix
    ../../modules/home/notifications.nix
    ../../modules/home/filemanager.nix
    ../../modules/home/clipboard.nix
    ../../modules/home/screenshot.nix
    ../../modules/home/apps.nix
    ../../modules/home/gaming.nix
  ];

  home.username = "jkoch";
  home.homeDirectory = "/home/jkoch";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Base packages not covered by specific modules
  home.packages = with pkgs; [
    wget
    curl
    ripgrep
    fd
    eza
    bat
    unzip
    zip
    htop
    pavucontrol
  ];
}

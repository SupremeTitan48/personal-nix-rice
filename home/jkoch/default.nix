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
    ../../modules/home/nightlight.nix
  ];

  home.username = "jkoch";
  home.homeDirectory = "/home/jkoch";
  home.stateVersion = "24.11";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;        # no Desktop folder
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    publicShare = null;
    templates = null;
  };

  programs.home-manager.enable = true;

  # Base packages not covered by specific modules
  home.packages = with pkgs; [
    wget
    curl
    ripgrep
    fd
    unzip
    zip
    htop
    pavucontrol
  ];
}

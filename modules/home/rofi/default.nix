# modules/home/rofi/default.nix
{ config, pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    extraConfig = {
      modi = "drun,run,wallpaper:${config.home.homeDirectory}/.local/bin/rofi-wallpaper";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun = " Apps";
      display-run = " Run";
      display-wallpaper = " Wallpaper";
      terminal = "kitty";
      font = "JetBrains Mono 12";
    };

    theme = ./style.rasi;
  };
}

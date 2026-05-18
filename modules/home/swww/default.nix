# modules/home/swww/default.nix
# swww handles wallpaper display and crossfade transitions.
# The actual wallpaper set + matugen pipeline lives in change-wallpaper.sh.
{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.awww ];

  # Install change-wallpaper as a user binary
  home.file.".local/bin/change-wallpaper" = {
    source = ../../../scripts/change-wallpaper.sh;
    executable = true;
  };

  # Install rofi wallpaper modi script
  home.file.".local/bin/rofi-wallpaper" = {
    source = ../matugen/rofi-wallpaper.sh;
    executable = true;
  };
}

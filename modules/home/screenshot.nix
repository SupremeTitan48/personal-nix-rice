# modules/home/screenshot.nix
# grimblast is Hyprland's wrapper around grim+slurp for screenshots.
# Keybinds are in hyprland/keybinds.nix:
#   Print          → grimblast copy output   (fullscreen to clipboard)
#   Super+Print    → grimblast copy area     (region to clipboard)
#   Super+Shift+Print → grimblast save area  (region to file)
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    grimblast
    grim
    slurp
  ];

  # Ensure screenshots directory exists
  home.file."Pictures/screenshots/.gitkeep".text = "";
}

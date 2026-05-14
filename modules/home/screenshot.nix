# modules/home/screenshot.nix
# grimblast is Hyprland's wrapper around grim+slurp for screenshots.
# Keybinds are in hyprland/keybinds.nix:
#   Print          → grimblast save output   (fullscreen to file with notify)
#   Super+Print    → grimblast copy area | satty  (region → satty for annotation)
#   Super+Shift+Print → grimblast save area  (region to file)
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    grimblast
    grim
    slurp
    satty              # screenshot annotation tool
  ];

  # Ensure screenshots directory exists
  home.file."Pictures/screenshots/.gitkeep".text = "";
}

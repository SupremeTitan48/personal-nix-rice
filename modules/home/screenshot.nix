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
    wf-recorder        # screen recording (toggled via Super+Shift+R)
  ];

  # Ensure media directories exist
  home.file."Pictures/screenshots/.gitkeep".text = "";
  home.file."Videos/Recordings/.gitkeep".text = "";
}

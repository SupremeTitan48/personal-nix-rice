# modules/home/clipboard.nix
# wl-clipboard provides wl-copy/wl-paste for Wayland clipboard access.
# cliphist stores clipboard history. Both are started in hyprland exec-once.
# The keybind Super+V is in hyprland/keybinds.nix.
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];
}

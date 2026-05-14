# modules/home/gaming.nix
# User-level gaming config. System-level (steam, gamemode) is in modules/nixos/gaming.nix.
{ config, pkgs, lib, ... }:
{
  # protonup-qt for managing Proton-GE versions via GUI
  home.packages = with pkgs; [
    protonup-qt
    heroic
  ];

  # Default Gamescope flags for Wayland + NVIDIA
  # Usage: gamescope -W 2560 -H 1440 -r 240 --backend drm -- %command%
  # Add this to Steam launch options per-game.
  home.file.".config/gamescope-flags".text = ''
    # Paste these into Steam launch options, replacing %command%:
    # gamescope -W 2560 -H 1440 -r 240 --backend drm -- %command%
    #
    # With MangoHud:
    # gamescope -W 2560 -H 1440 -r 240 --backend drm -- mangohud %command%
  '';
}

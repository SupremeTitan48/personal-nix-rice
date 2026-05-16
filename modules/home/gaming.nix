# modules/home/gaming.nix
# User-level gaming config. System-level (steam, gamemode) is in modules/nixos/gaming.nix.
{ config, pkgs, lib, ... }:
{
  # protonup-qt for managing Proton-GE versions via GUI
  home.packages = with pkgs; [
    protonup-qt
    heroic
    prismlauncher
  ];

  # MangoHud declarative config
  # Toggle HUD in-game: Shift_R+F12 | Toggle logging: Shift_L+F2
  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    legacy_layout=0
    fps
    frame_timing=1
    gpu_stats
    gpu_temp
    cpu_stats
    cpu_temp
    ram
    vram
    time
    fps_limit_method=late
    toggle_hud=Shift_R+F12
    toggle_logging=Shift_L+F2
    output_folder=${config.home.homeDirectory}/Games/MangoHud
    log_duration=30
  '';
}

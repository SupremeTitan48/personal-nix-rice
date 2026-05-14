# modules/nixos/gaming.nix
{ config, pkgs, lib, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # Use system Gamescope for Steam sessions
    gamescopeSession.enable = true;
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = -10;
        softrealtime = "auto";
        ioprio = 0;
      };
      # gpu block omitted: NVIDIA clock tuning is card-specific (add nv_core_clock_mhz_offset when profiled)
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    lutris
    heroic                              # Epic/GOG launcher
    protonup-qt                         # manage Proton-GE versions
  ];

  # Allow gamemode to adjust process priorities
  security.pam.loginLimits = [
    { domain = "@gamemode"; type = "-"; item = "nice"; value = "-10"; }
  ];
}

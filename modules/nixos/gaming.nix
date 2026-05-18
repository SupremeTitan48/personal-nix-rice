# modules/nixos/gaming.nix
{ config, pkgs, lib, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;  # desktop rig, not a game server
    # Use system Gamescope for Steam sessions
    gamescopeSession.enable = true;
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = -10;
        ioprio = 0;
      };
      cpu = {
        governor = "performance";
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    # lutris  # temporarily removed - openldap build test failure
  ];

  # Allow gamemode to adjust process priorities
  security.pam.loginLimits = [
    { domain = "@gamemode"; type = "-"; item = "nice"; value = "-10"; }
  ];

  # Kernel parameters for gaming performance
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;   # required for some games (e.g. Elden Ring, DXVK)
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
  };

  powerManagement.cpuFreqGovernor = "schedutil";
}

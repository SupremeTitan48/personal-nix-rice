# modules/nixos/nvidia.nix
{ config, pkgs, lib, userConfig, ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    # open = true  → RTX 30xx (Ampere) and newer only
    # open = false → GTX / RTX 20xx / older — set in user-config.nix
    open = userConfig.nvidiaOpen;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Required for Wayland + hardware video decode
  hardware.graphics = {
    enable = true;
    enable32Bit = true;                   # for Steam/Wine 32-bit games
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}

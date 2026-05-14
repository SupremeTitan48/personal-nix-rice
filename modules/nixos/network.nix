# modules/nixos/network.nix
{ config, pkgs, lib, ... }:
{
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.Policy.AutoEnable = "true";
  };
  services.blueman.enable = true;

  # Open firewall for KDE Connect / local discovery if needed later
  networking.firewall.enable = true;
}

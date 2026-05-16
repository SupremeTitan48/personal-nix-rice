# modules/nixos/network.nix
{ config, pkgs, lib, ... }:
{
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  services.resolved = {
    enable = true;
    dnssec = "opportunistic";
    settings.DNSOverTLS = "opportunistic";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;  # don't auto-enable Bluetooth; enable manually when needed
    settings.Policy.AutoEnable = "false";
  };
  services.blueman.enable = true;

  networking.firewall.enable = true;
}

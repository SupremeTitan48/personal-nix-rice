# hosts/desktop/default.nix
{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/portal.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/display-manager.nix
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.jkoch = {
    isNormalUser = true;
    description = "Jackson Koch";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" "input" ];
    shell = pkgs.fish;
  };

  # Allow sudo for wheel group
  security.sudo.wheelNeedsPassword = true;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # Fish shell must be enabled at NixOS level for /etc/shells and PAM integration
  programs.fish.enable = true;

  # dconf needed by GTK4/libadwaita settings and Home Manager GTK module
  programs.dconf.enable = true;

  # earlyoom — kill runaway processes before OOM killer kicks in
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
  };

  system.stateVersion = "24.11";
}

# hosts/desktop/default.nix
{ config, pkgs, inputs, userConfig, ... }:
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
    ../../modules/nixos/auto-upgrade.nix
    ../../modules/nixos/keyring.nix
    ../../modules/nixos/printing.nix
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.gitName;
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

  # gvfs provides trash, SMB, and MTP support for file managers.
  services.gvfs.enable = true;

  # earlyoom — kill runaway processes before OOM killer kicks in
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
  };

  system.stateVersion = "24.11";
}

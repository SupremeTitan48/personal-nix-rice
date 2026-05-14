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

  system.stateVersion = "24.11";
}

# modules/nixos/audio.nix
{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  # Disable PulseAudio (replaced by PipeWire)
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  nix-gaming.pipewireLowLatency.enable = true;
}

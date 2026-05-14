# modules/nixos/audio.nix
{ config, pkgs, lib, ... }:
{
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
}

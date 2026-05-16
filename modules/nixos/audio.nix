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

    # Low-latency config (equivalent to nix-gaming's pipewireLowLatency module)
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 64;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 8192;
      };
    };
  };
}

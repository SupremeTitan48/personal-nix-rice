{ config, pkgs, lib, inputs, userConfig, ... }:
let
  quickshellDev = userConfig.quickshellDev or false;
  overlayDir = ../../../overlays/ii;
  iiConfig = pkgs.runCommand "illogical-impulse-quickshell-config" { } ''
    mkdir -p "$out"
    cp -R ${inputs.end4-dots}/dots/.config/quickshell/ii/. "$out/"
    chmod -R u+w "$out"
    cp -R ${overlayDir}/. "$out/"
  '';
  iiQuickshell = import ./package.nix {
    inherit pkgs;
    quickshell = inputs.quickshell;
  };
in
{
  imports = [
    ./deps.nix
    ./config.nix
    ./dev.nix
  ];

  programs.quickshell = {
    enable = true;
    package = iiQuickshell;
    activeConfig = "ii";
    configs = lib.optionalAttrs (!quickshellDev) {
      ii = iiConfig;
    };

    systemd = {
      enable = true;
      # UWSM does not use Home Manager's default Hyprland session target.
      # graphical-session.target is the stable target UWSM activates.
      target = "graphical-session.target";
    };
  };
}

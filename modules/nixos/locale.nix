# modules/nixos/locale.nix
{ config, pkgs, lib, ... }:
{
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.keyMap = "us";
}

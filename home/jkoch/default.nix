# home/jkoch/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ../../modules/home/hyprland/default.nix
    ../../modules/home/waybar/default.nix
    ../../modules/home/rofi/default.nix
    ../../modules/home/hyprlock/default.nix
    ../../modules/home/swww/default.nix
    ../../modules/home/matugen.nix
    ../../modules/home/theme.nix
    ../../modules/home/terminal.nix
    ../../modules/home/git.nix
    ../../modules/home/notifications.nix
    ../../modules/home/filemanager.nix
    ../../modules/home/clipboard.nix
    ../../modules/home/screenshot.nix
    ../../modules/home/apps.nix
    ../../modules/home/gaming.nix
    ../../modules/home/nightlight.nix
  ];

  home.username = "jkoch";
  home.homeDirectory = "/home/jkoch";
  home.stateVersion = "24.11";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;        # no Desktop folder
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    publicShare = null;
    templates = null;
  };

  programs.home-manager.enable = true;

  # UWSM env vars — propagated to D-Bus activated services under UWSM.
  # Hyprland's own env = [] list does NOT reach D-Bus services, so we use this file instead.
  xdg.configFile."uwsm/env-hyprland".text = ''
    export LIBVA_DRIVER_NAME=nvidia
    export XDG_SESSION_TYPE=wayland
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export NVD_BACKEND=direct
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export XCURSOR_THEME=Bibata-Modern-Ice
    export XCURSOR_SIZE=24
    export HYPRCURSOR_THEME=Bibata-Modern-Ice
    export HYPRCURSOR_SIZE=24
  '';

  # Base packages not covered by specific modules
  # Note: fd is in terminal.nix (fzf backend), bat declared via programs.bat
  home.packages = with pkgs; [
    wget
    curl
    ripgrep
    unzip
    zip
    htop
    pavucontrol
  ];
}

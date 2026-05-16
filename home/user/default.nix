# home/user/default.nix — Home Manager entry point for the desktop user.
# Username and home directory come from user-config.nix via userConfig specialArg.
{ config, pkgs, inputs, lib, userConfig, ... }:
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
    ../../modules/home/wlogout.nix
    ../../modules/home/dock.nix
    ../../modules/home/scratchpads.nix
    ../../modules/home/udiskie.nix
  ];

  home.username    = userConfig.username;
  home.homeDirectory = "/home/${userConfig.username}";
  home.stateVersion = "24.11";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;
    documents = "${config.home.homeDirectory}/Documents";
    download  = "${config.home.homeDirectory}/Downloads";
    music     = "${config.home.homeDirectory}/Music";
    pictures  = "${config.home.homeDirectory}/Pictures";
    videos    = "${config.home.homeDirectory}/Videos";
    publicShare = null;
    templates   = null;
  };

  programs.home-manager.enable = true;

  # UWSM env vars — propagated to D-Bus activated services under UWSM.
  # Hyprland's own env = [] list does NOT reach D-Bus services.
  xdg.configFile."uwsm/env-hyprland".text = ''
    export LIBVA_DRIVER_NAME=nvidia
    export XDG_SESSION_TYPE=wayland
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export NVD_BACKEND=direct
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export QT_STYLE_OVERRIDE=kvantum
    export QT_QPA_PLATFORMTHEME=kvantum
    export XCURSOR_THEME=Bibata-Modern-Ice
    export XCURSOR_SIZE=24
    export HYPRCURSOR_THEME=Bibata-Modern-Ice
    export HYPRCURSOR_SIZE=24
  '';

  home.sessionPath = [ "$HOME/.local/bin" ];

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

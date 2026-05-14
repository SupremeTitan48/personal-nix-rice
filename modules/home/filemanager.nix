# modules/home/filemanager.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler                 # thumbnail service
    gvfs                         # trash, smb, MTP support
    ffmpegthumbnailer            # video thumbnails
    file-roller                  # archive manager integration
  ];

  # Ensure gvfs runs as a user service (tumbler is auto-activated via D-Bus from the package)
  services.gvfs.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"          = [ "thunar.desktop" ];
      "text/html"                = [ "google-chrome.desktop" ];
      "x-scheme-handler/http"    = [ "google-chrome.desktop" ];
      "x-scheme-handler/https"   = [ "google-chrome.desktop" ];
      "x-scheme-handler/about"   = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      "application/pdf"          = [ "google-chrome.desktop" ];
      "video/mp4"                = [ "mpv.desktop" ];
      "video/mkv"                = [ "mpv.desktop" ];
      "video/webm"               = [ "mpv.desktop" ];
      "video/x-matroska"         = [ "mpv.desktop" ];
      "image/jpeg"               = [ "imv.desktop" ];
      "image/png"                = [ "imv.desktop" ];
      "image/gif"                = [ "imv.desktop" ];
      "image/webp"               = [ "imv.desktop" ];
    };
  };
}

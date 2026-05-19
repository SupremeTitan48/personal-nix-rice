# modules/home/filemanager.nix
{ config, pkgs, lib, ... }:
{
  programs.zathura = {
    enable = true;
    options = {
      default-bg          = "#0d0f14";
      default-fg          = "#c8d3f5";
      statusbar-bg        = "#1a1d2e";
      statusbar-fg        = "#c8d3f5";
      inputbar-bg         = "#1a1d2e";
      inputbar-fg         = "#c8d3f5";
      completion-bg       = "#1a1d2e";
      completion-fg       = "#c8d3f5";
      completion-highlight-bg = "#5b9cf6";
      completion-highlight-fg = "#0d0f14";
      highlight-color         = "#5b9cf6";
      highlight-active-color  = "#86e1ca";
      recolor            = true;
      recolor-lightcolor = "#0d0f14";
      recolor-darkcolor  = "#c8d3f5";
    };
  };

  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.kio-extras
    gvfs                         # trash, smb, MTP support
    ffmpegthumbnailer            # video thumbnails
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"          = [ "org.kde.dolphin.desktop" ];
      "text/html"                = [ "google-chrome.desktop" ];
      "x-scheme-handler/http"    = [ "google-chrome.desktop" ];
      "x-scheme-handler/https"   = [ "google-chrome.desktop" ];
      "x-scheme-handler/about"   = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      "application/pdf"          = [ "org.pwmt.zathura.desktop" ];
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

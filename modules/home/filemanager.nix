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
      "inode/directory" = [ "thunar.desktop" ];
    };
  };
}

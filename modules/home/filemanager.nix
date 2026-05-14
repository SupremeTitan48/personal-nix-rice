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

  # Ensure gvfs and tumbler run as user services
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
    };
  };
}

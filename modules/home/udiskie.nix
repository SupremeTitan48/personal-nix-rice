# modules/home/udiskie.nix — auto-mount USB drives with system tray icon
#
# Plugging in a USB drive mounts it automatically under /run/media/$USER/.
# Right-click the tray icon to safely eject/unmount.
{ ... }:
{
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };
}

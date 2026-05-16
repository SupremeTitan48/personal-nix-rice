# modules/home/dock.nix — nwg-dock-hyprland app dock
# A GTK3 dock at the bottom with pinned apps and running windows.
# Toggle: Super+D  |  Auto-hides when a window is maximised.
{ config, pkgs, ... }:
{
  home.packages = [ pkgs.nwg-dock-hyprland ];

  # Pinned apps — these always show in the dock regardless of what's running.
  # Order: launcher, browser, terminal, notes, files, code, music, system
  xdg.configFile."nwg-dock-hyprland/pinned".text = ''
    google-chrome-stable
    kitty
    obsidian
    thunar
    vscodium
    steam
    pavucontrol
  '';

  xdg.configFile."nwg-dock-hyprland/style.css".text = ''
    @import "${config.home.homeDirectory}/.cache/matugen/waybar-colors.css";

    window {
      background: none;
      border: none;
    }

    #box {
      background-color: rgba(24, 28, 36, 0.75);
      backdrop-filter: blur(16px);
      border-radius: 16px;
      border: 1px solid rgba(255, 255, 255, 0.08);
      padding: 4px 8px;
      margin: 0 0 6px 0;
    }

    button {
      background: none;
      border: none;
      border-radius: 10px;
      padding: 4px;
      margin: 2px;
      transition: background-color 0.15s ease;
    }

    button:hover {
      background-color: alpha(@accent, 0.2);
    }

    button:active {
      background-color: alpha(@accent, 0.35);
    }

    image {
      padding: 2px;
    }

    #active-indicator {
      background-color: alpha(@accent, 0.8);
      border-radius: 2px;
      min-height: 3px;
      min-width: 20px;
      margin-bottom: 2px;
    }
  '';
}

# modules/home/waybar/default.nix
{ config, pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = [{
      layer = "top";
      position = "top";
      height = 36;
      margin-top = 8;
      margin-left = 180;
      margin-right = 180;
      margin-bottom = 0;
      exclusive = true;
      passthrough = false;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "mpris" "clock" ];
      modules-right = [ "memory" "cpu" "temperature" "pulseaudio" "network" "tray" ];

      "hyprland/window" = {
        format = "{}";
        max-length = 50;
        separate-outputs = true;
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = "○";
          active = "●";
        };
        on-click = "activate";
        sort-by-number = true;
        # persistent-workspaces removed — Hyprland workspace rules handle persistence
      };

      "mpris" = {
        format = "{player_icon} {title}";
        format-paused = "{status_icon} {title}";
        player-icons = {
          default = "▶";
          mpv = "🎵";
        };
        status-icons = {
          paused = "⏸";
        };
        max-length = 40;
        ignored-players = [ "firefox" ];
      };

      "memory" = {
        interval = 5;
        format = " {}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        warning = 80;
        critical = 95;
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %B %d %Y  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = " {usage}%";
        interval = 2;
        tooltip = false;
      };

      temperature = {
        format = " {temperatureC}°C";
        # AMD Ryzen uses k10temp driver — thermal-zone is portable across boards
        thermal-zone = 0;
        critical-threshold = 80;
        format-critical = " {temperatureC}°C";
        interval = 5;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 Muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "pavucontrol";
        scroll-step = 5;
      };

      network = {
        format-wifi = " {signalStrength}%";
        format-ethernet = "󰈀 {ipaddr}";
        format-disconnected = "󰤭 Offline";
        tooltip-format-wifi = "{essid} ({signalStrength}%) via {ifname}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
        interval = 5;
      };

      tray = {
        spacing = 8;
        icon-size = 16;
      };
    }];

    # Replace hardcoded home path so config is portable across users
    style = builtins.replaceStrings
      [ "/home/jkoch" ]
      [ config.home.homeDirectory ]
      (builtins.readFile ./style.css);
  };
}

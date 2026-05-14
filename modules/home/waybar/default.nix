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

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "cpu" "temperature" "pulseaudio" "network" "tray" ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "●";
          "2" = "●";
          "3" = "●";
          "4" = "●";
          "5" = "●";
          default = "○";
          active = "●";
          empty = "○";
        };
        on-click = "activate";
        sort-by-number = true;
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
        };
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
        hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
        input-filename = "temp1_input";
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

    # CSS is written separately to leverage matugen's @import
    style = builtins.readFile ./style.css;
  };
}

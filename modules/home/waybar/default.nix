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

      modules-left = [ "hyprland/workspaces" "custom/submap" "hyprland/window" ];
      modules-center = [ "mpris" "clock" ];
      modules-right = [ "custom/gpu" "memory" "cpu" "temperature" "disk" "pulseaudio" "network" "tray" ];

      "hyprland/window" = {
        format = "{}";
        max-length = 50;
        separate-outputs = true;
      };

      "hyprland/workspaces" = {
        format = "{id} {windows}";
        format-window-separator = " ";
        window-rewrite-default = "";
        window-rewrite = {
          "class<kitty>" = "";
          "class<google-chrome>" = "󰊯";
          "class<chromium>" = "󰊯";
          "class<firefox>" = "";
          "class<obsidian>" = "󰝴";
          "class<vesktop>" = "󰙯";
          "class<discord>" = "󰙯";
          "class<steam>" = "󰓓";
          "class<steam_app_.*>" = "󰓓";
          "class<thunar>" = "󰉋";
          "class<io.missioncenter.MissionCenter>" = "󰓻";
          "class<sidra>" = "󰎈";
          "class<claude>" = "󰚩";
          "class<code>" = "󰨞";
          "class<kitty-scratch>" = "";
        };
        on-click = "activate";
        sort-by-number = true;
      };

      "custom/submap" = {
        exec = "[ -f /tmp/hypr-submap ] && printf '󰙖 %s' \"$(cat /tmp/hypr-submap | tr a-z A-Z)\" || true";
        interval = 1;
        format = "{}";
        tooltip = false;
      };

      "custom/gpu" = {
        exec = "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F', ' '{printf \" %s%% %s°C\", $1, $2}'";
        interval = 3;
        tooltip = false;
        format = "{}";
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
        format = "%H:%M\n<span size='small'>%a %b %d</span>";
        format-alt = "{:%A, %B %d %Y  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = " {usage}%";
        interval = 2;
        tooltip = false;
      };

      temperature = {
        interval = 5;
        # AMD Ryzen k10temp — zone 2 is typical for Ryzen on most boards.
        # If the reading is 0 or wrong, check: cat /sys/class/thermal/thermal_zone*/type
        # and adjust thermal-zone to match the k10temp entry.
        thermal-zone = 2;
        critical-threshold = 85;
        format-critical = " {temperatureC}°C";
        format = " {temperatureC}°C";
        tooltip = true;
      };

      disk = {
        interval = 30;
        format = "󰋊 {percentage_used}%";
        path = "/";
        tooltip-format = "{used} / {total}";
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

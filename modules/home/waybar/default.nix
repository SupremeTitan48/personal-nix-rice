# modules/home/waybar/default.nix
{ config, pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = [{
      layer = "top";
      position = "top";
      height = 40;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;
      margin-bottom = 0;
      exclusive = true;
      passthrough = false;

      modules-left = [ "hyprland/workspaces" "custom/submap" "hyprland/window" ];
      modules-center = [ "mpris" "clock" ];
      modules-right = [ "custom/stats" "pulseaudio" "network" "custom/swaync" "tray" ];

      "hyprland/window" = {
        format = "{}";
        max-length = 50;
        separate-outputs = true;
      };

      "hyprland/workspaces" = {
        format = "{id}";
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
          "class<kitty-bluetuith>" = "󰂯";
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

      "custom/stats" = {
        exec = "${config.home.homeDirectory}/.local/bin/waybar-stats";
        return-type = "json";
        interval = 3;
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

      clock = {
        format = "{:%H:%M  %a %b %d}";
        format-alt = "{:%A, %B %d %Y  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 Muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "swaync-client -t -sw";
        on-click-right = "pavucontrol";
        scroll-step = 5;
      };

      "custom/swaync" = {
        format = "{icon}";
        format-icons = {
          notification = "󱅫";
          none = "󰂚";
          dnd-notification = "󱅫";
          dnd-none = "󰂛";
          inhibited-notification = "󱅫";
          inhibited-none = "󰂚";
          dnd-inhibited-notification = "󱅫";
          dnd-inhibited-none = "󰂛";
        };
        return-type = "json";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
      };

      network = {
        format-wifi = " {signalStrength}%";
        format-ethernet = "󰈀 {ipaddr}";
        format-disconnected = "󰤭 Offline";
        tooltip-format-wifi = "{essid} ({signalStrength}%) via {ifname}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
        interval = 5;
        on-click = "networkmanager_dmenu";
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

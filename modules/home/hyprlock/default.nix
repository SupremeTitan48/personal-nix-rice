# modules/home/hyprlock/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
        grace = 0;
        pam_module = "login";
      };

      background = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/wallpapers/default.jpg";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.5;
          vibrancy = 0.1696;
          contrast = 0.8916;
          noise = 0.0117;
        }
      ];

      # Large clock centered on screen
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b>$(date +"%H:%M")</b>"'';
          color = "rgba(232, 232, 240, 1.0)";
          font_size = 80;
          font_family = "JetBrains Mono Bold";
          shadow_passes = 2;
          shadow_size = 4;
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(date +"%A, %B %d")"'';
          color = "rgba(152, 152, 168, 1.0)";
          font_size = 18;
          font_family = "JetBrains Mono";
          position = "0, 40";
          halign = "center";
          valign = "center";
        }
      ];

      # Glass password input pill
      input-field = [
        {
          monitor = "";
          size = "300, 50";
          outline_thickness = 2;
          dots_size = 0.26;
          dots_spacing = 0.64;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgba(255, 255, 255, 0.15)";
          inner_color = "rgba(13, 15, 20, 0.7)";
          font_color = "rgba(232, 232, 240, 1.0)";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = ''<span foreground="##9898a8">󰌾  Password</span>'';
          hide_input = false;
          rounding = 25;
          check_color = "rgba(91, 156, 246, 1.0)";
          fail_color = "rgba(242, 139, 130, 1.0)";
          fail_text = ''<i>$FAIL <b>($ATTEMPTS)</b></i>'';
          fail_transition = 300;
          capslock_color = "rgba(251, 188, 5, 1.0)";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}

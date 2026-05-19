# modules/home/hyprlock/default.nix
{ config, pkgs, inputs, lib, ... }:
{
  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

    # Source matugen-generated color variables before the rest of the config
    extraConfig = ''
      source = ${config.home.homeDirectory}/.cache/matugen/hyprlock-colors.conf
    '';

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
          path = "${config.home.homeDirectory}/wallpapers/default.png";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.5;
          vibrancy = 0.1696;
          contrast = 0.8916;
          noise = 0.0117;
        }
      ];

      image = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/.face";
          size = 100;
          rounding = -1;
          border_size = 2;
          border_color = "$accent";
          position = "0, 240";
          halign = "center";
          valign = "center";
        }
      ];

      # Large clock centered on screen
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b>$(date +"%H:%M")</b>"'';
          color = "$text";
          font_size = 80;
          font_family = "JetBrainsMono Nerd Font Bold";
          shadow_passes = 2;
          shadow_size = 4;
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(date +"%A, %B %d")"'';
          color = "$text_muted";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 20";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] h=$(date +%H); if [ "$h" -lt 12 ]; then echo "Good morning"; elif [ "$h" -lt 17 ]; then echo "Good afternoon"; else echo "Good evening"; fi'';
          color = "$text_muted";
          font_size = 14;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -10";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "Type password to unlock";
          color = "$text_muted";
          font_size = 11;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -160";
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
          inner_color = "$surface";
          font_color = "$text";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = ''<span foreground="##9898a8">󰌾  Password</span>'';
          hide_input = false;
          rounding = 25;
          check_color = "$accent";
          fail_color = "$error";
          fail_text = ''<i>$FAIL <b>($ATTEMPTS)</b></i>'';
          fail_transition = 300;
          capslock_color = "rgba(251, 188, 5, 1.0)";
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}

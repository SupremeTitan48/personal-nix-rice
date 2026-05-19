# modules/home/notifications.nix
{ config, pkgs, lib, ... }:
{
  services.swaync = {
    enable = true;
    package = pkgs.swaynotificationcenter;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 8;
      control-center-margin-left = 0;
      notification-icon-size = 48;
      notification-close-button-size = 24;
      fit-to-screen = false;
      control-center-width = 380;
      control-center-height = 680;
      notification-window-width = 380;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;

      widgets = [
        "title"
        "buttons-grid"
        "volume"
        "mpris"
        "dnd"
        "notifications"
      ];

      widget-config = {
        title = {
          text = "Control Center";
          clear-all-button = true;
          button-text = "Clear All";
        };

        dnd = {
          text = "Do Not Disturb";
        };

        volume = {
          label = "󰕾";
          show-per-app = true;
          show-per-app-icon = true;
          show-per-app-label = false;
          expand-per-app = false;
        };

        mpris = {
          image-size = 64;
          image-radius = 8;
        };

        buttons-grid = {
          buttons-per-row = 4;
          actions = [
            {
              label = "󰤨";
              type = "toggle";
              active = true;
              command = "sh -c 'if [ \"$SWAYNC_TOGGLE_STATE\" = true ]; then nmcli radio wifi on; else nmcli radio wifi off; fi'";
              update-command = "sh -c 'nmcli radio wifi | grep -q enabled && echo true || echo false'";
            }
            {
              label = "󰂯";
              type = "toggle";
              active = false;
              command = "sh -c 'if [ \"$SWAYNC_TOGGLE_STATE\" = true ]; then rfkill unblock bluetooth; else rfkill block bluetooth; fi'";
              update-command = "sh -c 'rfkill list bluetooth | grep -q \"Soft blocked: no\" && echo true || echo false'";
            }
            {
              label = "󰝟";
              type = "toggle";
              active = true;
              command = "sh -c 'if [ \"$SWAYNC_TOGGLE_STATE\" = true ]; then pactl set-sink-mute @DEFAULT_SINK@ 0; else pactl set-sink-mute @DEFAULT_SINK@ 1; fi'";
              update-command = "sh -c 'pactl get-sink-mute @DEFAULT_SINK@ | grep -q \"no\" && echo true || echo false'";
            }
            {
              label = "󰐥";
              command = "bash ${config.home.homeDirectory}/.local/bin/power-menu";
            }
          ];
        };
      };
    };

    style = ''
      /* swaync glassmorphism CSS */

      @define-color accent         #5b9cf6;
      @define-color accent_fg      #ffffff;
      @define-color surface        #181c24;
      @define-color surface_variant #242836;
      @define-color on_surface     #e8e8f0;
      @define-color on_surface_variant #9898a8;
      @define-color outline        rgba(255,255,255,0.10);

      * {
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", "Font Awesome 6 Free", sans-serif;
        font-size: 13px;
        transition: all 0.2s ease;
      }

      .control-center {
        background: rgba(13, 15, 20, 0.80);
        border: 1px solid @outline;
        border-radius: 16px;
        color: @on_surface;
        padding: 12px;
      }

      /* ── Title ─────────────────────────────────── */
      .widget-title {
        margin-bottom: 8px;
      }
      .widget-title > box > label {
        font-size: 14px;
        font-weight: bold;
        color: @on_surface;
      }
      .widget-title > box > button {
        background: alpha(@accent, 0.15);
        border: 1px solid alpha(@accent, 0.30);
        border-radius: 8px;
        color: @accent;
        padding: 4px 10px;
        font-size: 11px;
      }
      .widget-title > box > button:hover {
        background: alpha(@accent, 0.30);
      }

      /* ── Buttons grid ───────────────────────────── */
      .widget-buttons-grid {
        margin: 6px 0;
      }
      .toggle-button {
        background: @surface_variant;
        border: 1px solid @outline;
        border-radius: 14px;
        color: @on_surface_variant;
        min-height: 56px;
        min-width: 56px;
        font-size: 20px;
        margin: 3px;
      }
      .toggle-button:hover {
        background: rgba(255, 255, 255, 0.10);
        color: @on_surface;
      }
      .toggle-button.active {
        background: alpha(@accent, 0.20);
        border-color: alpha(@accent, 0.50);
        color: @accent;
      }
      .toggle-button.active:hover {
        background: alpha(@accent, 0.30);
      }

      /* ── Volume ─────────────────────────────────── */
      .widget-volume {
        background: @surface_variant;
        border: 1px solid @outline;
        border-radius: 12px;
        padding: 10px 14px;
        margin: 6px 0;
      }
      .widget-volume > box > image {
        color: @on_surface_variant;
        font-size: 16px;
        margin-right: 8px;
      }
      .per-app-volume {
        background: transparent;
        border: none;
        padding: 2px 0;
      }
      scale trough {
        background: rgba(255, 255, 255, 0.12);
        border-radius: 4px;
        min-height: 4px;
      }
      scale trough highlight {
        background: @accent;
        border-radius: 4px;
      }
      scale slider {
        background: @accent;
        border-radius: 50%;
        min-height: 14px;
        min-width: 14px;
        margin: -5px 0;
      }

      /* ── MPRIS ──────────────────────────────────── */
      .widget-mpris {
        background: @surface_variant;
        border: 1px solid @outline;
        border-radius: 12px;
        padding: 12px;
        margin: 6px 0;
      }
      .widget-mpris image {
        border-radius: 8px;
        margin-right: 12px;
      }
      .widget-mpris-title {
        font-weight: bold;
        font-size: 13px;
        color: @on_surface;
      }
      .widget-mpris-subtitle {
        font-size: 11px;
        color: @on_surface_variant;
      }
      .widget-mpris button {
        background: transparent;
        border: none;
        border-radius: 8px;
        color: @on_surface;
        font-size: 18px;
        padding: 4px 8px;
      }
      .widget-mpris button:hover {
        background: rgba(255, 255, 255, 0.08);
      }

      /* ── DND ────────────────────────────────────── */
      .widget-dnd {
        margin: 6px 0;
      }
      .widget-dnd > switch {
        border-radius: 12px;
      }
      .widget-dnd > switch:checked {
        background: @accent;
      }

      /* ── Notifications ──────────────────────────── */
      .notification-row {
        outline: none;
        margin-bottom: 4px;
      }
      .notification {
        background: rgba(24, 28, 36, 0.85);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 12px;
        color: @on_surface;
      }
      .notification:hover {
        background: rgba(36, 40, 54, 0.90);
      }
      .notification-content {
        background: transparent;
      }
      .notification-default-action {
        background: transparent;
        border-radius: 12px;
      }
      .notification-default-action:hover {
        background: rgba(255, 255, 255, 0.06);
      }
      .notification-action {
        background: rgba(255, 255, 255, 0.06);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 8px;
        color: @on_surface;
        margin: 4px 2px 0;
      }
      .notification-action:hover {
        background: alpha(@accent, 0.25);
        border-color: alpha(@accent, 0.40);
      }
      .close-button {
        background: rgba(255, 255, 255, 0.06);
        border-radius: 50%;
        color: @on_surface_variant;
        min-height: 24px;
        min-width: 24px;
      }
      .close-button:hover {
        background: rgba(242, 139, 130, 0.30);
        color: #f28b82;
      }

      /* matugen overrides — wins because it comes after the fallback block */
      @import "${config.home.homeDirectory}/.cache/matugen/swaync-colors.css";
    '';
  };
}

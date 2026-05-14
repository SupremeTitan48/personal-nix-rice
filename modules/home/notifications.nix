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
      control-center-height = 580;
      notification-window-width = 380;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widgets = [ "inhibitors" "title" "dnd" "notifications" ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
      };
    };

    style = ''
      /* swaync glassmorphism CSS */

      /* Fallback colors — matugen @import below overrides these when cache exists */
      @define-color accent         #5b9cf6;
      @define-color accent_fg      #ffffff;
      @define-color surface        #181c24;
      @define-color surface_variant #242836;
      @define-color on_surface     #e8e8f0;
      @define-color on_surface_variant #9898a8;
      @define-color outline        rgba(255,255,255,0.10);

      * {
        font-family: "JetBrains Mono", sans-serif;
        font-size: 13px;
        transition: all 0.2s ease;
      }

      .control-center {
        background: rgba(13, 15, 20, 0.75);
        border: 1px solid @outline;
        border-radius: 16px;
        color: @on_surface;
        padding: 8px;
      }

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
        background: rgba(36, 40, 54, 0.9);
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
        border-color: alpha(@accent, 0.4);
      }

      .close-button {
        background: rgba(255, 255, 255, 0.06);
        border-radius: 50%;
        color: @on_surface_variant;
        min-height: 24px;
        min-width: 24px;
      }

      .close-button:hover {
        background: rgba(242, 139, 130, 0.3);
        color: #f28b82;
      }

      .widget-title label {
        font-size: 14px;
        font-weight: bold;
        color: @on_surface;
      }

      .widget-title button {
        background: alpha(@accent, 0.2);
        border: 1px solid alpha(@accent, 0.3);
        border-radius: 8px;
        color: @accent;
        padding: 4px 10px;
        font-size: 11px;
      }

      .widget-title button:hover {
        background: alpha(@accent, 0.35);
      }

      .widget-dnd trough {
        background: rgba(255, 255, 255, 0.08);
        border-radius: 12px;
      }

      .widget-dnd trough highlight {
        background: @accent;
        border-radius: 12px;
      }

      /* matugen overrides — wins because it comes after the fallback block */
      @import "${config.home.homeDirectory}/.cache/matugen/swaync-colors.css";
    '';
  };
}

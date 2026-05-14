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

      * {
        font-family: "JetBrains Mono", sans-serif;
        font-size: 13px;
        transition: all 0.2s ease;
      }

      .control-center {
        background: rgba(13, 15, 20, 0.75);
        border: 1px solid rgba(255, 255, 255, 0.10);
        border-radius: 16px;
        color: #e8e8f0;
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
        color: #e8e8f0;
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
        color: #e8e8f0;
        margin: 4px 2px 0;
      }

      .notification-action:hover {
        background: rgba(91, 156, 246, 0.25);
        border-color: rgba(91, 156, 246, 0.4);
      }

      .close-button {
        background: rgba(255, 255, 255, 0.06);
        border-radius: 50%;
        color: #9898a8;
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
        color: #e8e8f0;
      }

      .widget-title button {
        background: rgba(91, 156, 246, 0.2);
        border: 1px solid rgba(91, 156, 246, 0.3);
        border-radius: 8px;
        color: #5b9cf6;
        padding: 4px 10px;
        font-size: 11px;
      }

      .widget-title button:hover {
        background: rgba(91, 156, 246, 0.35);
      }

      .widget-dnd trough {
        background: rgba(255, 255, 255, 0.08);
        border-radius: 12px;
      }

      .widget-dnd trough highlight {
        background: #5b9cf6;
        border-radius: 12px;
      }
    '';
  };
}

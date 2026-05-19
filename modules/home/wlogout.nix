# modules/home/wlogout.nix — power menu overlay (Super+Escape)
# Buttons: lock · logout · suspend · reboot · shutdown
{ config, pkgs, ... }:
{
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "hyprlock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "logout",
        "action" : "hyprctl dispatch exit 0",
        "text" : "Logout",
        "keybind" : "o"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "s"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "p"
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    /* Fallback colors — overridden by matugen import if cache exists */
    @define-color accent         #5b9cf6;
    @define-color surface_variant #242836;
    @define-color on_surface     #e8e8f0;
    @define-color on_accent      #ffffff;

    @import "${config.home.homeDirectory}/.cache/matugen/waybar-colors.css";

    * {
      background-image: none;
      box-shadow: none;
      border: none;
      outline: none;
    }

    window {
      background-color: rgba(13, 15, 20, 0.85);
      font-family: "JetBrains Mono", monospace;
    }

    button {
      color: @on_surface;
      background-color: alpha(@surface_variant, 0.6);
      border-radius: 16px;
      margin: 12px;
      min-width: 160px;
      min-height: 160px;
      border: 1px solid rgba(255, 255, 255, 0.08);
      font-size: 13px;
      background-size: 64px;
      background-repeat: no-repeat;
      background-position: center 40px;
      padding-top: 110px;
      transition: background-color 0.2s ease, border-color 0.2s ease;
    }

    button:hover {
      background-color: alpha(@accent, 0.25);
      border-color: alpha(@accent, 0.6);
      color: @on_accent;
    }

    button:active {
      background-color: alpha(@accent, 0.45);
    }

    #lock     { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
    #logout   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
    #suspend  { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
    #reboot   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
    #shutdown { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
  '';
}

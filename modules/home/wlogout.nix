# modules/home/wlogout.nix — power menu overlay (Super+Escape)
# Buttons: lock · logout · suspend · reboot · shutdown
{ config, pkgs, ... }:
{
  # White SVG icons — GTK3 has no CSS filter support so we deploy our own
  xdg.configFile."wlogout/icons/lock.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path fill="white" d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
    </svg>
  '';
  xdg.configFile."wlogout/icons/logout.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path fill="white" d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5-5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/>
    </svg>
  '';
  xdg.configFile."wlogout/icons/suspend.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path fill="white" d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z"/>
    </svg>
  '';
  xdg.configFile."wlogout/icons/reboot.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path fill="white" d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
    </svg>
  '';
  xdg.configFile."wlogout/icons/shutdown.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path fill="white" d="M13 3h-2v10h2V3zm4.83 2.17l-1.42 1.42C17.99 7.86 19 9.81 19 12c0 3.87-3.13 7-7 7s-7-3.13-7-7c0-2.19 1.01-4.14 2.58-5.42L6.17 5.17C4.23 6.82 3 9.26 3 12c0 4.97 4.03 9 9 9s9-4.03 9-9c0-2.74-1.23-5.18-3.17-6.83z"/>
    </svg>
  '';

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
      background-color: rgba(13, 15, 20, 0.92);
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

    #lock     { background-image: image(url("${config.xdg.configHome}/wlogout/icons/lock.svg")); }
    #logout   { background-image: image(url("${config.xdg.configHome}/wlogout/icons/logout.svg")); }
    #suspend  { background-image: image(url("${config.xdg.configHome}/wlogout/icons/suspend.svg")); }
    #reboot   { background-image: image(url("${config.xdg.configHome}/wlogout/icons/reboot.svg")); }
    #shutdown { background-image: image(url("${config.xdg.configHome}/wlogout/icons/shutdown.svg")); }
  '';
}

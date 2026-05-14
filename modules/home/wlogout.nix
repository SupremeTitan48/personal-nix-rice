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
    * {
      background-image: none;
      box-shadow: none;
      border: none;
      outline: none;
    }

    window {
      background-color: rgba(13, 15, 20, 0.85);
      backdrop-filter: blur(20px);
    }

    button {
      color: #e8e8f0;
      background-color: rgba(36, 40, 54, 0.6);
      border-radius: 16px;
      margin: 8px;
      border: 1px solid rgba(255, 255, 255, 0.08);
      font-family: "JetBrains Mono", monospace;
      font-size: 14px;
      transition: background-color 0.2s ease, border-color 0.2s ease;
    }

    button:hover {
      background-color: rgba(91, 156, 246, 0.25);
      border-color: rgba(91, 156, 246, 0.6);
      color: #ffffff;
    }

    button:active {
      background-color: rgba(91, 156, 246, 0.45);
    }

    #lock     { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
    #logout   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
    #suspend  { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
    #reboot   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
    #shutdown { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
  '';
}

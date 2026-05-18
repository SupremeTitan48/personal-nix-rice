# modules/home/scratchpads.nix — named scratchpad workspaces
{ pkgs, ... }:
{
  home.packages = [ pkgs.mission-center ];

  wayland.windowManager.hyprland.extraConfig = ''
    # Terminal scratchpad
    windowrule = workspace special:term, match:class kitty-scratch
    windowrule = float true, match:class kitty-scratch
    windowrule = size 70% 65%, match:class kitty-scratch
    windowrule = center true, match:class kitty-scratch

    # Obsidian scratchpad
    windowrule = workspace special:obsidian, match:class obsidian
    windowrule = float true, match:class obsidian
    windowrule = size 85% 85%, match:class obsidian
    windowrule = center true, match:class obsidian

    # System monitor scratchpad
    windowrule = workspace special:monitor, match:class io.missioncenter.MissionCenter
    windowrule = float true, match:class io.missioncenter.MissionCenter
    windowrule = size 80% 80%, match:class io.missioncenter.MissionCenter
    windowrule = center true, match:class io.missioncenter.MissionCenter
  '';
}

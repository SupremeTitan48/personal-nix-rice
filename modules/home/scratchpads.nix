# modules/home/scratchpads.nix — named scratchpad workspaces
#
# Scratchpads live on hidden special workspaces and slide in over any workspace
# when toggled. They remember size and position between calls.
#
# Binds (Super+Alt+<key>, defined in keybinds.nix):
#   T — terminal (kitty)
#   O — Obsidian notes
#   M — system monitor (Mission Center)
#
# exec-once pre-spawn entries live in hyprland/default.nix.
{ pkgs, ... }:
{
  home.packages = [ pkgs.mission-center ];

  wayland.windowManager.hyprland.extraConfig = ''
    # Terminal scratchpad
    windowrule = workspace special:term, class:(kitty-scratch)
    windowrule = float, class:(kitty-scratch)
    windowrule = size 70% 65%, class:(kitty-scratch)
    windowrule = center, class:(kitty-scratch)

    # Obsidian scratchpad
    windowrule = workspace special:obsidian, class:(obsidian)
    windowrule = float, class:(obsidian)
    windowrule = size 85% 85%, class:(obsidian)
    windowrule = center, class:(obsidian)

    # System monitor scratchpad
    windowrule = workspace special:monitor, class:(io.missioncenter.MissionCenter)
    windowrule = float, class:(io.missioncenter.MissionCenter)
    windowrule = size 80% 80%, class:(io.missioncenter.MissionCenter)
    windowrule = center, class:(io.missioncenter.MissionCenter)
  '';
}

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
# exec-once pre-spawn entries live in hyprland/default.nix — assigning
# settings."exec-once" in a second module would overwrite the main list.
{ pkgs, ... }:
{
  # mission-center must be installed; it is exec-once'd in hyprland/default.nix
  home.packages = [ pkgs.mission-center ];

  wayland.windowManager.hyprland.settings = {
    # windowrulev2 required for size/center rules (windowrule only supports float/workspace)
    windowrulev2 = [
      # Terminal scratchpad
      "workspace special:term, class:(kitty-scratch)"
      "float, class:(kitty-scratch)"
      "size 70% 65%, class:(kitty-scratch)"
      "center, class:(kitty-scratch)"

      # Obsidian scratchpad
      "workspace special:obsidian, class:(obsidian)"
      "float, class:(obsidian)"
      "size 85% 85%, class:(obsidian)"
      "center, class:(obsidian)"

      # System monitor scratchpad
      "workspace special:monitor, class:(io.missioncenter.MissionCenter)"
      "float, class:(io.missioncenter.MissionCenter)"
      "size 80% 80%, class:(io.missioncenter.MissionCenter)"
      "center, class:(io.missioncenter.MissionCenter)"
    ];
  };
}

# modules/home/scratchpads.nix — named scratchpad workspaces
#
# Scratchpads live on hidden special workspaces and slide in over any workspace
# when toggled. They remember position between calls. Pre-spawned at login so
# the first toggle is instant.
#
# Binds (Super+Alt+<key>):
#   T — terminal (kitty)
#   O — Obsidian notes
#   M — system monitor (Mission Center)
{ ... }:
{
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

  # Pre-spawn scratchpads silently at login so the first toggle is instant.
  # Thunar is intentionally excluded — it is single-instance and does not support
  # a custom --class flag, making scratchpad workspace assignment unreliable.
  # Use Super+E to open Thunar in the normal workspace instead.
  wayland.windowManager.hyprland.settings."exec-once" = [
    "[workspace special:term silent] kitty --class=kitty-scratch"
    "[workspace special:obsidian silent] obsidian"
    "[workspace special:monitor silent] mission-center"
  ];
}

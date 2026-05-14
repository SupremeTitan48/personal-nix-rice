# modules/home/scratchpads.nix — named scratchpad workspaces
#
# Scratchpads are persistent floating windows that live on hidden special
# workspaces. Toggle them with a keybind — they slide in over any workspace
# and slide out when dismissed, remembering size and position.
#
# Binds (defined in keybinds.nix, window rules here):
#   Super+Alt+T   — terminal scratchpad (kitty)
#   Super+Alt+O   — Obsidian notes
#   Super+Alt+F   — file manager (Thunar)
#   Super+Alt+M   — system monitor (Mission Center)
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Terminal scratchpad
      "workspace special:term, class:(kitty-scratch)"
      "size 70% 65%, class:(kitty-scratch)"
      "center, class:(kitty-scratch)"
      "float, class:(kitty-scratch)"

      # Obsidian scratchpad
      "workspace special:obsidian, class:(obsidian)"
      "size 85% 85%, class:(obsidian)"
      "center, class:(obsidian)"
      "float, class:(obsidian)"

      # Thunar scratchpad
      "workspace special:files, class:(thunar-scratch)"
      "size 75% 70%, class:(thunar-scratch)"
      "center, class:(thunar-scratch)"
      "float, class:(thunar-scratch)"

      # System monitor scratchpad
      "workspace special:monitor, class:(io.missioncenter.MissionCenter)"
      "size 80% 80%, class:(io.missioncenter.MissionCenter)"
      "center, class:(io.missioncenter.MissionCenter)"
      "float, class:(io.missioncenter.MissionCenter)"
    ];
  };

  # Pre-spawn all scratchpads silently at login so the first toggle is instant.
  wayland.windowManager.hyprland.settings."exec-once" = [
    "[workspace special:term silent] kitty --class=kitty-scratch"
    "[workspace special:obsidian silent] obsidian"
    "[workspace special:files silent] thunar --class=thunar-scratch"
    "[workspace special:monitor silent] mission-center"
  ];
}

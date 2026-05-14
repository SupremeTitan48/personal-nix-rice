# modules/home/matugen.nix
{ config, pkgs, lib, ... }:
let
  templateDir = ./matugen/templates;
  cacheDir = "${config.home.homeDirectory}/.cache/matugen";
in
{
  home.packages = [ pkgs.matugen ];

  # matugen config tells it where to find templates and where to write outputs
  xdg.configFile."matugen/config.toml".text = ''
    [config]
    reload_apps_list = []

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/hyprland-colors.conf"
    output_path = "${cacheDir}/hyprland-colors.conf"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/waybar-colors.css"
    output_path = "${cacheDir}/waybar-colors.css"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/rofi-colors.rasi"
    output_path = "${cacheDir}/rofi-colors.rasi"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/kitty-colors.conf"
    output_path = "${cacheDir}/kitty-colors.conf"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/gtk-colors.css"
    output_path = "${cacheDir}/gtk-colors.css"
  '';

  # Deploy templates into ~/.config/matugen/templates/
  xdg.configFile."matugen/templates/hyprland-colors.conf".source =
    "${templateDir}/hyprland-colors.conf";
  xdg.configFile."matugen/templates/waybar-colors.css".source =
    "${templateDir}/waybar-colors.css";
  xdg.configFile."matugen/templates/rofi-colors.rasi".source =
    "${templateDir}/rofi-colors.rasi";
  xdg.configFile."matugen/templates/kitty-colors.conf".source =
    "${templateDir}/kitty-colors.conf";
  xdg.configFile."matugen/templates/gtk-colors.css".source =
    "${templateDir}/gtk-colors.css";

  # Run matugen on first login (generates cache from default wallpaper)
  home.activation.matugenInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALLPAPER="${config.home.homeDirectory}/wallpapers/default.jpg"
    CACHE="${cacheDir}"
    mkdir -p "$CACHE"
    if [ -f "$WALLPAPER" ]; then
      $DRY_RUN_CMD ${pkgs.matugen}/bin/matugen image "$WALLPAPER" --mode dark || true
    fi
  '';
}

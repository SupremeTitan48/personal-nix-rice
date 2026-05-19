# modules/home/matugen.nix
{ config, pkgs, lib, ... }:
let
  templateDir = ./matugen/templates;
  cacheDir = "${config.home.homeDirectory}/.cache/matugen";
  quickshellState = "${config.home.homeDirectory}/.local/state/quickshell/user/generated";
in
{
  home.packages = [ pkgs.matugen ];

  xdg.configFile."matugen/config.toml".text = ''
    [config]
    reload_apps_list = []

    [templates.hyprland-colors]
    input_path = "${config.xdg.configHome}/matugen/templates/hyprland-colors.conf"
    output_path = "${cacheDir}/hyprland-colors.conf"

    [templates.gtk-colors]
    input_path = "${config.xdg.configHome}/matugen/templates/gtk-colors.css"
    output_path = "${cacheDir}/gtk-colors.css"

    [templates.kvantum-colors]
    input_path = "${config.xdg.configHome}/matugen/templates/kvantum-colors.kvconfig"
    output_path = "${config.home.homeDirectory}/.config/Kvantum/MatugenGlass/MatugenGlass.kvconfig"

    [templates.quickshell-colors]
    input_path = "${config.xdg.configHome}/matugen/templates/quickshell-colors.json"
    output_path = "${quickshellState}/colors.json"
  '';

  xdg.configFile."matugen/templates/hyprland-colors.conf".source =
    "${templateDir}/hyprland-colors.conf";
  xdg.configFile."matugen/templates/gtk-colors.css".source =
    "${templateDir}/gtk-colors.css";
  xdg.configFile."matugen/templates/kvantum-colors.kvconfig".source =
    "${templateDir}/kvantum-colors.kvconfig";
  xdg.configFile."matugen/templates/quickshell-colors.json".source =
    "${templateDir}/quickshell-colors.json";

  home.activation.matugenInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALLPAPER="${config.home.homeDirectory}/wallpapers/default.jpg"
    CACHE="${cacheDir}"
    QS_STATE="${quickshellState}"

    mkdir -p "$CACHE" "$QS_STATE" "$HOME/.config/Kvantum/MatugenGlass"
    if [ -f "$WALLPAPER" ]; then
      $DRY_RUN_CMD ${pkgs.matugen}/bin/matugen image "$WALLPAPER" --mode dark || true
    fi

    if [ ! -f "$CACHE/hyprland-colors.conf" ]; then
      cat > "$CACHE/hyprland-colors.conf" << 'EOF'
$accent           = rgba(5b9cf6ff)
$accent_dim       = rgba(5b9cf6aa)
$surface          = rgba(181c24ff)
$accent_secondary = rgba(c792eaff)
$on_surface       = rgba(e8e8f0ff)
$accent_shadow    = rgba(5b9cf622)
EOF
    fi

    if [ ! -f "$CACHE/gtk-colors.css" ]; then
      cat > "$CACHE/gtk-colors.css" << 'EOF'
@define-color accent_color          #5b9cf6;
@define-color accent_bg_color       #5b9cf6;
@define-color accent_fg_color       #ffffff;
@define-color window_bg_color       #181c24;
@define-color window_fg_color       #e8e8f0;
@define-color view_bg_color         #242836;
@define-color view_fg_color         #e8e8f0;
@define-color headerbar_bg_color    #181c24;
@define-color headerbar_fg_color    #e8e8f0;
@define-color popover_bg_color      #242836;
@define-color card_bg_color         #242836;
@define-color card_fg_color         #e8e8f0;
@define-color sidebar_bg_color      #181c24;
@define-color sidebar_fg_color      #e8e8f0;
EOF
    fi

    if [ ! -f "$QS_STATE/colors.json" ]; then
      cat > "$QS_STATE/colors.json" << 'EOF'
{
  "background": "#0d0f14",
  "error": "#f28b82",
  "error_container": "#5f1f1f",
  "inverse_on_surface": "#181c24",
  "inverse_primary": "#1a3a6e",
  "inverse_surface": "#e8e8f0",
  "on_background": "#e8e8f0",
  "on_error": "#ffffff",
  "on_error_container": "#ffffff",
  "on_primary": "#ffffff",
  "on_primary_container": "#ffffff",
  "on_primary_fixed": "#181c24",
  "on_primary_fixed_variant": "#242836",
  "on_secondary": "#ffffff",
  "on_secondary_container": "#ffffff",
  "on_secondary_fixed": "#181c24",
  "on_secondary_fixed_variant": "#242836",
  "on_surface": "#e8e8f0",
  "on_surface_variant": "#9898a8",
  "on_tertiary": "#ffffff",
  "on_tertiary_container": "#ffffff",
  "on_tertiary_fixed": "#181c24",
  "on_tertiary_fixed_variant": "#242836",
  "outline": "#3a4254",
  "outline_variant": "#242836",
  "primary": "#5b9cf6",
  "primary_container": "#1a3a6e",
  "primary_fixed": "#aec8f5",
  "primary_fixed_dim": "#5b9cf6",
  "scrim": "#000000",
  "secondary": "#8bcbb8",
  "secondary_container": "#24463d",
  "secondary_fixed": "#8bcbb8",
  "secondary_fixed_dim": "#5b9cf6",
  "shadow": "#000000",
  "surface": "#181c24",
  "surface_bright": "#242836",
  "surface_container": "#181c24",
  "surface_container_high": "#242836",
  "surface_container_highest": "#303548",
  "surface_container_low": "#10131a",
  "surface_container_lowest": "#0d0f14",
  "surface_dim": "#0d0f14",
  "surface_tint": "#5b9cf6",
  "surface_variant": "#242836",
  "tertiary": "#c792ea",
  "tertiary_container": "#3d2454",
  "tertiary_fixed": "#c792ea",
  "tertiary_fixed_dim": "#8b8bdc"
}
EOF
    fi

    if [ ! -f "$HOME/.config/Kvantum/MatugenGlass/MatugenGlass.kvconfig" ]; then
      cat > "$HOME/.config/Kvantum/MatugenGlass/MatugenGlass.kvconfig" << 'EOF'
[General]
author=MatugenGlass
comment=Stub - replaced by matugen on wallpaper change
composite=true
translucent_windows=true
blurring=true
popup_blurring=true
dark_titlebar=true
opaque_colors=false

[GeneralColors]
window.color=#181c24
base.color=#242836
button.color=#242836
highlight.color=#5b9cf6
text.color=#e8e8f0
window.text.color=#e8e8f0
button.text.color=#e8e8f0
highlight.text.color=#ffffff
EOF
    fi
  '';
}

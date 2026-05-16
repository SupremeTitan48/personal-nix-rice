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

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/swaync-colors.css"
    output_path = "${cacheDir}/swaync-colors.css"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/hyprlock-colors.conf"
    output_path = "${cacheDir}/hyprlock-colors.conf"

    [[templates]]
    input_path = "${config.xdg.configHome}/matugen/templates/kvantum-colors.kvconfig"
    output_path = "${config.home.homeDirectory}/.config/Kvantum/MatugenGlass/MatugenGlass.kvconfig"
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
  xdg.configFile."matugen/templates/swaync-colors.css".source =
    "${templateDir}/swaync-colors.css";
  xdg.configFile."matugen/templates/hyprlock-colors.conf".source =
    "${templateDir}/hyprlock-colors.conf";
  xdg.configFile."matugen/templates/kvantum-colors.kvconfig".source =
    "${templateDir}/kvantum-colors.kvconfig";

  # Run matugen on first login (generates cache from default wallpaper)
  home.activation.matugenInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALLPAPER="${config.home.homeDirectory}/wallpapers/default.jpg"
    CACHE="${cacheDir}"
    mkdir -p "$CACHE"
    if [ -f "$WALLPAPER" ]; then
      $DRY_RUN_CMD ${pkgs.matugen}/bin/matugen image "$WALLPAPER" --mode dark || true
    fi
    # Write stub color files so rofi/waybar/kitty don't crash on first boot
    # if matugen hasn't run yet (missing wallpaper or matugen failure).
    if [ ! -f "$CACHE/rofi-colors.rasi" ]; then
      cat > "$CACHE/rofi-colors.rasi" << 'EOF'
* {
    accent:          #5b9cf6;
    accent-dim:      #1a3a6e;
    on-accent:       #ffffff;
    surface:         #181c24;
    surface-variant: #242836;
    on-surface:      #e8e8f0;
    muted:           #9898a8;
    error:           #f28b82;
}
EOF
    fi
    if [ ! -f "$CACHE/waybar-colors.css" ]; then
      cat > "$CACHE/waybar-colors.css" << 'EOF'
@define-color accent         #5b9cf6;
@define-color accent_container #1a3a6e;
@define-color on_accent      #ffffff;
@define-color surface        #181c24;
@define-color surface_variant #242836;
@define-color on_surface     #e8e8f0;
@define-color muted          #9898a8;
@define-color error          #f28b82;
EOF
    fi
    if [ ! -f "$CACHE/hyprland-colors.conf" ]; then
      cat > "$CACHE/hyprland-colors.conf" << 'EOF'
$accent       = rgba(5b9cf6ff)
$accent_dim   = rgba(5b9cf6aa)
$surface      = rgba(181c24ff)
$accent_secondary = rgba(c792eaff)
EOF
    fi
    if [ ! -f "$CACHE/kitty-colors.conf" ]; then
      cat > "$CACHE/kitty-colors.conf" << 'EOF'
background  #0d0f14
foreground  #e8e8f0
cursor       #5b9cf6
color0   #181c24
color1   #f28b82
color2   #5b9cf6
color3   #8bcbb8
color4   #5b9cf6
color5   #8b8bdc
color6   #8bcbb8
color7   #e8e8f0
color8   #242836
color9   #f28b82
color10  #aec8f5
color11  #8bcbb8
color12  #aec8f5
color13  #8b8bdc
color14  #242836
color15  #e8e8f0
EOF
    fi
    if [ ! -f "$CACHE/swaync-colors.css" ]; then
      cat > "$CACHE/swaync-colors.css" << 'EOF'
@define-color accent         #5b9cf6;
@define-color accent_fg      #ffffff;
@define-color surface        #181c24;
@define-color surface_variant #242836;
@define-color on_surface     #e8e8f0;
@define-color on_surface_variant #9898a8;
@define-color outline        rgba(255,255,255,0.10);
EOF
    fi
    if [ ! -f "$CACHE/hyprlock-colors.conf" ]; then
      cat > "$CACHE/hyprlock-colors.conf" << 'EOF'
$accent = rgb(5b9cf6)
$accent_bg = rgba(5b9cf633)
$text = rgb(e8e8f0)
$text_muted = rgb(9898a8)
$surface = rgb(181c24)
$error = rgb(ff6e6e)
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
    mkdir -p "$HOME/.config/Kvantum/MatugenGlass"
    if [ ! -f "$HOME/.config/Kvantum/MatugenGlass/MatugenGlass.kvconfig" ]; then
      cat > "$HOME/.config/Kvantum/MatugenGlass/MatugenGlass.kvconfig" << 'EOF'
[General]
author=MatugenGlass
comment=Stub - replace by running change-wallpaper
composite=true
translucent_windows=true
blurring=true
popup_blurring=true
reduce_window_opacity=10
reduce_menu_opacity=15
dark_titlebar=true
opaque_colors=false
animate_states=true
alt_mnemonic=true
kinetic_scrolling=true
transient_scrollbar=true
left_tabs=true

[GeneralColors]
window.color=#181c24
base.color=#242836
alt.base.color=#242836
button.color=#242836
light.color=#242836
mid.light.color=#181c24
mid.color=#181c24
dark.color=#181c24
shadow.color=#000000
highlight.color=#5b9cf6
inactive.highlight.color=#1a3a6e
text.color=#e8e8f0
window.text.color=#e8e8f0
button.text.color=#e8e8f0
disabled.text.color=#9898a8
tooltip.text.color=#e8e8f0
highlight.text.color=#ffffff
link.color=#5b9cf6
link.visited.color=#9898a8
EOF
    fi
  '';
}

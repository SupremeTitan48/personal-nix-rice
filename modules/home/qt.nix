# modules/home/qt.nix — Qt app theming via Kvantum
#
# Without this, Qt apps (VSCodium, KDE Connect, KeePassXC, etc.) render with
# the default system Qt style — looks completely out of place next to GTK apps.
# Kvantum uses SVG-based themes that can match the glassmorphism aesthetic.
{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      name = "kvantum-dark";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  # qt6ct: GUI configurator for advanced Qt6 theming (fonts, icon theme, etc.)
  home.packages = with pkgs; [
    qt6ct
    libsForQt5.qt5ct
  ];
}

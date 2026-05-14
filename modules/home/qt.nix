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

  # Both Qt5 and Qt6 Kvantum plugins needed — kdePackages covers Qt6 apps,
  # libsForQt5 covers legacy Qt5 apps (KeePassXC, older utilities, etc.)
  home.packages = with pkgs; [
    qt6ct
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
  ];
}

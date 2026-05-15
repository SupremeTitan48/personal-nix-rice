# modules/home/theme.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    adw-gtk3
    bibata-cursors
    hyprcursor
    papirus-icon-theme
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
  ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # Inject matugen accent into GTK3 and GTK4
  xdg.configFile."gtk-3.0/gtk.css".text = ''
    @import "${config.home.homeDirectory}/.cache/matugen/gtk-colors.css";
  '';

  xdg.configFile."gtk-4.0/gtk.css".text = ''
    @import "${config.home.homeDirectory}/.cache/matugen/gtk-colors.css";
  '';

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      name = "kvantum-dark";
      # kdePackages provides the Qt6 Kvantum plugin; libsForQt5 (in home.packages)
      # covers Qt5 apps. HM uses this package to set QT_STYLE_OVERRIDE correctly.
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # Pointer cursor for X11 fallback (xwayland apps)
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}

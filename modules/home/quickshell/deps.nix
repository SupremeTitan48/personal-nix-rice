{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Core commands used by end-4's Quickshell services and scripts.
    bc
    brightnessctl
    cliphist
    cmake
    curlFull
    dbus
    ddcutil
    eza
    foot
    fuzzel
    glib
    hypridle
    hyprpicker
    hyprshot
    hyprsunset
    imagemagick
    inetutils
    jq
    libnotify
    libqalculate
    matugen
    playerctl
    ripgrep
    rsync
    slurp
    swappy
    tesseract
    upower
    uv
    wget
    wf-recorder
    wl-clipboard
    wtype
    xdg-user-dirs
    xorg.xlsclients
    ydotool
    yq-go

    # Audio and tray/menu integrations.
    libcava
    libdbusmenu-gtk3
    lxqt.pavucontrol-qt

    # Fonts and themes expected by illogical-impulse.
    adw-gtk3
    bibata-cursors
    fontconfig
    material-symbols
    nerd-fonts.jetbrains-mono
    rubik
    starship
    twemoji-color-font

    # KDE components used by end-4 network, bluetooth, and settings actions.
    kdePackages.bluedevil
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.dolphin
    kdePackages.kconfig
    kdePackages.plasma-nm
    kdePackages.systemsettings

    # Geolocation powers weather and automatic night-light behavior.
    (geoclue2.override { withDemoAgent = true; })
  ];
}

# modules/home/apps.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    hyprpicker         # screen color picker
    wlr-randr          # runtime monitor management
    mission-center     # GTK4 system monitor
    xdg-utils          # xdg-open, MIME handling

    # VSCodium with Wayland flags
    (vscodium.override {
      commandLineArgs = [
        "--enable-features=WaylandWindowDecorations"
        "--ozone-platform-hint=auto"
      ];
    })
  ];

  # VSCodium: use open-vsx instead of Microsoft marketplace
  xdg.configFile."VSCodium/product.json".text = builtins.toJSON {
    extensionsGallery = {
      serviceUrl = "https://open-vsx.org/vscode/gallery";
      itemUrl = "https://open-vsx.org/vscode/item";
    };
  };
}

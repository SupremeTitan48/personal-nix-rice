# modules/home/apps.nix
{ config, pkgs, lib, inputs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "nvdec";           # NVIDIA hardware video decode
      vo = "gpu-next";
      gpu-api = "vulkan";
      profile = "gpu-hq";
      video-sync = "display-resample";
    };
  };

  home.packages = with pkgs; [
    google-chrome
    obsidian           # markdown notes (requires allowUnfree)
    claude-code        # Claude AI CLI — run `claude` in terminal (requires allowUnfree)
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default

    obs-studio        # screen recording and streaming
    keepassxc         # local password manager (no cloud dependency)
    gnome-disk-utility # GUI disk/partition management and SMART data

    imv              # lightweight Wayland image viewer
    hyprpicker         # screen color picker
    wlr-randr          # runtime monitor management
    xdg-utils          # xdg-open, MIME handling
    nwg-look           # GTK theme / cursor / icons GUI (Wayland-compatible)
    wlogout            # power menu overlay

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

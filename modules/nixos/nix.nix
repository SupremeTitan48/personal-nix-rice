{ inputs, pkgs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+ggJal6efWkVMC8a+GpkFXabdRXjR7Grzg="
      "nix-community.cachix.org-1:mB9FSh9qf2dde0enM6RFkgR2XNMrsk5BqCFynLrNqj0="
    ];
    auto-optimise-store = true;
    flake-registry = "";  # disable global flake registry for reproducibility
    max-jobs = "auto";    # use all CPU cores for parallel builds
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  # Pin flake registry so `nix run nixpkgs#foo` uses the locked revision
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}

{
  description = "NixOS desktop configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude desktop app — not in nixpkgs; community repackage of the official release
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sidra — Apple Music client for Linux
    sidra = {
      url = "github:wimpysworld/sidra";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # swww — wallpaper daemon with crossfade transitions (removed from nixpkgs)
    swww.url = "github:LGFae/swww";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprlock, claude-desktop, sidra, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    # Load the single file a newcomer must fill in before their first build.
    userConfig = import ./user-config.nix;
  in
  {
    formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
      nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
    );

    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nil           # Nix LSP
            statix        # Nix linter
            deadnix       # dead code finder
          ];
        };
      }
    );

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit system;
      # userConfig is available in every NixOS module as a function argument.
      specialArgs = { inherit inputs userConfig; };
      modules = [
        ./hosts/desktop/default.nix
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # userConfig is available in every Home Manager module as a function argument.
          home-manager.extraSpecialArgs = { inherit inputs userConfig; };
          home-manager.sharedModules = [ ];
          home-manager.users.${userConfig.username} = import ./home/user/default.nix;
        }
      ];
    };
  };
}

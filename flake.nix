{
  description = "jkoch NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, hyprlock, hypridle, nix-gaming, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
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
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/desktop/default.nix
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          # Provide hyprlock and hypridle HM modules to all users
          home-manager.sharedModules = [
            hyprlock.homeManagerModules.hyprlock
            hypridle.homeManagerModules.hypridle
          ];
          home-manager.users.jkoch = import ./home/jkoch/default.nix;
        }
      ];
    };
  };
}

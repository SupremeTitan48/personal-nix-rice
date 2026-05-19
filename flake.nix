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

    # Quickshell — Qt/QML desktop shell used by end-4's illogical-impulse setup
    quickshell = {
      url = "github:quickshell-mirror/quickshell/7511545ee20664e3b8b8d3322c0ffe7567c56f7a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # end-4's dotfiles are not a flake; consume them as a pinned source tree.
    end4-dots = {
      url = "github:end-4/dots-hyprland/c1b37bc4676677f7eeebfb2cf6185b493e38d2cd";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, claude-desktop, sidra, ... }@inputs:
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

{
  description = "Multi-platform Nix configuration for macOS and Android";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, nix-on-droid, home-manager, sops-nix, nix-index-database } @ inputs:
    let
      username = "bkase";
      hostname = "Brandons-MacBook-Pro";
      darwinSystem = "aarch64-darwin";
      droidSystem = "aarch64-linux";

      darwinPkgs = nixpkgs.legacyPackages.${darwinSystem};
      droidPkgs = nixpkgs.legacyPackages.${droidSystem};
    in
    {
      # macOS configuration
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        system = darwinSystem;

        specialArgs = { inherit inputs username hostname; };

        modules = [
          ./darwin/default.nix
          ./zsh/default.nix
          nix-index-database.darwinModules.nix-index
          home-manager.darwinModules.home-manager
          {
            programs.nix-index-database.comma.enable = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./darwin/home.nix;
              extraSpecialArgs = { inherit inputs username; };
            };
          }
        ];
      };

      # Android configuration
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = droidPkgs;
        modules = [
          ./droid/default.nix
          {
            home-manager = {
              config = ./droid/home.nix;
              extraSpecialArgs = { inherit inputs username; };
            };
          }
        ];
      };

      # Dev shells for both platforms
      devShells = {
        ${darwinSystem}.default = darwinPkgs.mkShell {
          buildInputs = with darwinPkgs; [
            jq
            ripgrep
            fd
            tree
            bat
            eza
            delta
            gh
            yq
            htop
          ];
        };

        ${droidSystem}.default = droidPkgs.mkShell {
          buildInputs = with droidPkgs; [
            jq
            ripgrep
            fd
            tree
            bat
            eza
            delta
            gh
            yq
            htop
          ];
        };
      };
    };
}
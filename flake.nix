{
  description = "Declarative Nix configuration for macOS (nix-darwin + home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-index-database } @ inputs:
    let
      username = "bkase";
      hostname = "Brandons-MacBook-Pro";
      darwinSystem = "aarch64-darwin";

      pkgs = nixpkgs.legacyPackages.${darwinSystem};
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

      # Dev shell with common CLI tools (`nix develop`)
      devShells.${darwinSystem}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
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

      # `nix fmt`
      formatter.${darwinSystem} = pkgs.nixfmt-rfc-style;
    };
}

{
  description = "Declarative macOS configuration using nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, nix-index-database } @ inputs: 
    let
      username = "bkase";
      hostname = "Brandons-MacBook-Pro";
      system = "aarch64-darwin";
      
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        
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
              users.${username} = import ./home/default.nix;
              extraSpecialArgs = { inherit inputs username; };
            };
          }
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
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
    };
}
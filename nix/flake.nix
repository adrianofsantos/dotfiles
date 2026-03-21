{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  {
    # $ darwin-rebuild switch --flake .#Aang
    darwinConfigurations."Aang" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self; };
      modules = [
        ./modules/common.nix
        ./modules/personal.nix
        ./modules/macos-defaults.nix
        ./modules/nix-settings.nix
        ./modules/proton.nix
        ./hosts/aang.nix
        nix-homebrew.darwinModules.nix-homebrew
        ./modules/rosetta.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.adrianofsantos = import ./home-aang.nix;
          };
        }
      ];
    };

    # $ darwin-rebuild switch --flake .#Kyoshi
    darwinConfigurations."Kyoshi" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self; };
      modules = [
        ./modules/common.nix
        ./modules/personal.nix
        ./modules/macos-defaults.nix
        ./modules/nix-settings.nix
        ./hosts/kyoshi.nix
        nix-homebrew.darwinModules.nix-homebrew
        ./modules/rosetta.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.adrianofsantos = import ./home-kyoshi.nix;
          };
        }
      ];
    };
  };
}

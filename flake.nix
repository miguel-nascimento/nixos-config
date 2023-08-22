{
  description = "Configuration for my NixOS waifus machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    hardware.url = "github:nixos/nixos-hardware"; # TODO: maybe I can remove this?

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

 outputs = { home-manager, nixpkgs, ... }@inputs:
  let
    mkHost = import ./lib/mkHost.nix { inherit inputs; };
  in
  {
    nixosConfigurations = {
      korone = mkHost {
        system = "x86_64-linux";
        users = [ "inugami" ];
        hostname = "korone";
      };

      pendragon = mkHost {
        system = "x86_64-linux";
        users = [ "miguel" ];
        hostname = "pendragon";
        modules = [ inputs.nixos-wsl.nixosModules.wsl ];
      };
    };

    homeConfigurations = { 
      miguel = home-manager.lib.homeManagerConfiguration {
        modules = [ users/miguel/home.nix ];
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      }; 

      miguel-m1 = home-manager.lib.homeManagerConfiguration {
        modules = [ users/miguel-m1/home.nix ];
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      };
    };
  };
}

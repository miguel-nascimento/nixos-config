{
  description = "Configuration for my NixOS waifus machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";

    hardware.url = "github:nixos/nixos-hardware"; # TODO: maybe I can remove this?

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

 outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (self) outputs;
    mkHost = import ./lib/mkHost.nix { inherit inputs outputs; };
  in 
  {
    overlays = import ./overlays { inherit inputs; };

    nixosConfigurations = {
      korone = mkHost {
        system = "x86_64-linux";
        users = [ "inugami" ];
        hostname = "korone";
        modules = [ inputs.agenix.nixosModules.default ];
      };

      pendragon = mkHost {
        system = "x86_64-linux";
        users = [ "miguel" ];
        hostname = "pendragon";
        modules = [ 
          inputs.nixos-wsl.nixosModules.wsl
          inputs.agenix.nixosModules.default
        ];
      };
    };

    homeConfigurations = { 
      miguel = home-manager.lib.homeManagerConfiguration {
        modules = [ users/miguel/home.nix ];
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };  
      }; 

      miguel-m1 = home-manager.lib.homeManagerConfiguration {
        modules = [ users/miguel-m1/home.nix ];
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = { inherit inputs outputs; };  
      };
    };
  };
}

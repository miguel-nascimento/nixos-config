{
  description = "Configuration for my NixOS waifus machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";

    hardware.url = "github:nixos/nixos-hardware"; # TODO: maybe I can remove this?

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    qmd.url = "github:tobi/qmd";
    herdr.url = "github:ogulcancelik/herdr";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      mkHost = import "${self}/lib/mkHost.nix" { inherit inputs outputs; };
    in
    {
      overlays = import "${self}/overlays" { inherit inputs; };

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

      darwinConfigurations = {
        m1-air = mkHost {
          system = "aarch64-darwin";
          users = [ "miguel" ];
          hostname = "m1-air";
        };
        m4-pro = mkHost {
          system = "aarch64-darwin";
          users = [ "miguel" ];
          hostname = "m4-pro";
          # Stays home, reached over Tailscale, so it never sleeps
          modules = [
            {
              power.sleep.computer = "never";
              power.sleep.display = 10;
            }
          ];
        };
        m5 = mkHost {
          system = "aarch64-darwin";
          users = [ "miguel" ];
          hostname = "m5";
        };
      };

      homeConfigurations = {
        miguel = home-manager.lib.homeManagerConfiguration {
          modules = [ "${self}/users/miguel/home.nix" ];
          # pendragon's packages: same nixpkgs, overlays and allowUnfree
          pkgs = self.nixosConfigurations.pendragon.pkgs;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };

      };
    };
}

{
  description = "Configuration for my NixOS waifus machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    hardware.url = "github:nixos/nixos-hardware"; # TODO: maybe I can remove this?

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    vscode-server.url = "github:msteen/nixos-vscode-server";
  };

   outputs = { ... }@inputs:
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

      # homeConfigs = { 
      #   inugami = home-manager.lib.homeManagerConfiguration {
      #     system = "x86_64-linux";
      #     users = [ "inugami" ];
      #     hostname = "inugami";
      #   };

      #   miguel = home-manager.lib.homeManagerConfiguration {
      #     system = "x86_64-linux";
      #     username = "miguel"
      #     pkgs 
      #   };
      # };
  };
}

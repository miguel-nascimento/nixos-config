{ inputs }:
let
  inherit (inputs) nixpkgs home-manager vscode-server;
in
{ hostname, system, users, modules ? [ ] }:
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs system hostname;
  };

  modules = [
    home-manager.nixosModule
    vscode-server.nixosModule
    # ../common/system/nix-config.nix

    (../hosts + "/${hostname}")
    {
      networking.hostName = hostname;

      nixpkgs = {
        # inherit overlays;

        config.allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        config.allowUnfreePredicate = (_: true);
      };

      services.vscode-server.enable = true;
      services.vscode-server.enableFHS = true;
      
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }
  ] ++ nixpkgs.lib.forEach users (user: ../users + "/${user}") ++ modules;
}

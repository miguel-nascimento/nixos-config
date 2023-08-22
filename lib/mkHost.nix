{ inputs }:
let
  inherit (inputs) nixpkgs home-manager;
in
{ hostname, system, users, modules ? [ ] }:
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs system hostname;
  };

  modules = [
    home-manager.nixosModule
    # ../common/system/nix-config.nix

    ../common/system/nix-config.nix
    (../hosts + "/${hostname}")
    {
      networking.hostName = hostname;

      nixpkgs = {
        # inherit overlays;

        config.allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        config.allowUnfreePredicate = (_: true);
      };

      programs.nix-ld.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }
  ] ++ nixpkgs.lib.forEach users (user: ../users + "/${user}") ++ modules;
}

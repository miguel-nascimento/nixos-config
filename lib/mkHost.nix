{ inputs, outputs }:
let
  inherit (inputs) nixpkgs home-manager;
in
{
  hostname,
  system,
  users,
  modules ? [ ],
}:
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs system hostname;
  };

  modules = [
    home-manager.nixosModule

    ../common/system/nix-config.nix
    (../hosts + "/${hostname}")
    {
      networking.hostName = hostname;

      nixpkgs = {
        # inherit overlays;
        overlays = [ outputs.overlays.unstable-packages ];

        config.allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        config.allowUnfreePredicate = (_: true);
      };

      programs.nix-ld.enable = true;
      # TODO: find a way to move this to /common/system/minimal.nix
      environment.systemPackages = with (nixpkgs.legacyPackages.${system}); [
        cachix
        vim
        wget
        htop
        unzip
      ];
      environment.variables.EDITOR = "vim";

      home-manager = {
        backupFileExtension = "hm-backup";
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };
    }
  ] ++ nixpkgs.lib.forEach users (user: ../users + "/${user}") ++ modules;
}

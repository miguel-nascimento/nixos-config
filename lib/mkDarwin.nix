{ inputs, outputs }:
let
  inherit (inputs) nix-darwin home-manager nix-homebrew self;
in
{
  hostname,
  user,
  modules ? [ ],
}:
nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";

  specialArgs = {
    inherit inputs outputs hostname user;
  };

  modules = [
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    "${self}/common/darwin"
    {
      home-manager = {
        backupFileExtension = "hm-backup";
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        users.${user} = import "${self}/users/miguel-mac.nix";
      };
    }
  ] ++ modules;
}

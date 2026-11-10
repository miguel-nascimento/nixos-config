# Builds any machine: nix-darwin for a `*-darwin` system, NixOS otherwise
{ inputs, outputs }:
let
  inherit (inputs)
    nixpkgs
    nix-darwin
    home-manager
    nix-homebrew
    self
    ;
in
{
  hostname,
  system,
  users,
  modules ? [ ],
}:
let
  # Every machine, and home-manager on it, gets the same packages
  shared = {
    nixpkgs = {
      overlays = [ outputs.overlays.unstable-packages ];
      config.allowUnfree = true;
    };

    home-manager = {
      backupFileExtension = "hm-backup";
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs outputs;
      };
    };
  };

  darwin =
    let
      # A Mac has one user; their home lives in users/<user>-mac.nix
      user = builtins.head users;
    in
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs outputs hostname user;
      };
      modules = [
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        "${self}/common/darwin"
        shared
        { home-manager.users.${user} = import "${self}/users/${user}-mac.nix"; }
      ]
      ++ modules;
    };

  nixos = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs system hostname;
    };
    modules = [
      home-manager.nixosModules.home-manager
      "${self}/common/system/nix-config.nix"
      "${self}/hosts/${hostname}"
      shared
      {
        networking.hostName = hostname;
        home-manager.useUserPackages = true;

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
      }
    ]
    ++ map (user: "${self}/users/${user}") users
    ++ modules;
  };
in
if nixpkgs.lib.hasSuffix "-darwin" system then darwin else nixos

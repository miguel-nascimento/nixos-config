{ outputs, ... }:
{
  programs.home-manager.enable = true;
  imports = [
    ../../common/home-manager/minimal.nix
    ../../common/home-manager/programs/direnv.nix
    ../../common/home-manager/programs/navi.nix
    ../../common/home-manager/programs/keychain.nix
    ../../common/home-manager/languages/docs.nix
    ../../common/home-manager/languages/typescript.nix
    ../../common/home-manager/languages/rust.nix
  ];

  # TODO: would be nice to share the same nixpkgs config as `mkHost.nix`
  nixpkgs = {
    # You can add overlays here
    overlays = [ outputs.overlays.unstable-packages ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "miguel";
    homeDirectory = "/Users/miguel";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.11";
  };
}

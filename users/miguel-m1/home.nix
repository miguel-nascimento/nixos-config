_:
{
  programs.home-manager.enable = true;
  imports = [
    ../../common/home-manager/minimal.nix
    ../../common/home-manager/programs/direnv.nix
    ../../common/home-manager/programs/navi.nix
    ../../common/home-manager/programs/keychain.nix
    
    ../../common/home-manager/languages/typescript.nix
    ../../common/home-manager/languages/rust.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "miguel";
    homeDirectory = "/Users/miguel";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05"; 
  };
}

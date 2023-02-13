_:
{
  imports = [
    ../../common/home-manager/minimal.nix
    ../../common/home-manager/programs/direnv.nix
    ../../common/home-manager/languages/typescript.nix
  ];

  home = {
    username = "miguel";
    homeDirectory = "/home/miguel";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.11"; 
  };
}

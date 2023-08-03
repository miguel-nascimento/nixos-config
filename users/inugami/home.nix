_:
{
  imports = [ ../../common/home-manager/minimal.nix ];

  home = {
    username = "inugami";
    homeDirectory = "/home/inugami";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05"; 
  };
}
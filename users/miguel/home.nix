{ ... }:
{
  programs.home-manager.enable = true;
  imports = [
    ../../common/home-manager/minimal.nix
    ../../common/home-manager/programs/direnv.nix
    ../../common/home-manager/programs/navi.nix
    ../../common/home-manager/programs/keychain.nix
    ../../common/home-manager/programs/gpg.nix
    ../../common/home-manager/programs/ai.nix
    ../../common/home-manager/languages/libc.nix
    ../../common/home-manager/languages/docs.nix
    ../../common/home-manager/languages/typescript.nix
    ../../common/home-manager/languages/rust.nix
    ../../common/home-manager/languages/zig.nix
  ];

  home = {
    username = "miguel";
    homeDirectory = "/home/miguel";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.11";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}

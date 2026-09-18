{ inputs, lib, pkgs, ... }:
{
  home.packages = [
    inputs.herdr.packages.${pkgs.system}.herdr
  ];

  # Herdr starts zsh as a login shell. On macOS, path_helper can move the
  # system paths ahead of Nix's paths after Nix has already marked its shell
  # setup as sourced, causing commands such as java to resolve from /usr/bin.
  programs.zsh.initContent = lib.mkAfter ''
    for profile in ''${(z)NIX_PROFILES}; do
      path=($profile/bin $path)
    done
  '';
}

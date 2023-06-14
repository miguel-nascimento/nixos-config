{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yarn
    openssl
    nodejs
    deno
    nodePackages.node-gyp
  ];
}

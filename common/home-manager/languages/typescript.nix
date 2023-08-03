{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yarn
    openssl
    nodejs-18_x
    deno
    nodePackages.node-gyp
  ];
}

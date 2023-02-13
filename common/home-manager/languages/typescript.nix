{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yarn
    openssl
    nodejs-16_x
    nodePackages.node-gyp
  ];
}

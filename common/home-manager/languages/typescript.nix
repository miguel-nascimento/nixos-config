{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yarn
    openssl
    nodejs-18_x
    nodePackages.node-gyp
    unstable.deno
    unstable.bun
  ];
}

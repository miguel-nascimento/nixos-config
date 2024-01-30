{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yarn
    openssl
    nodejs
    nodePackages.node-gyp
    unstable.deno
    unstable.bun
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    openssl
    nodejs_20
    nodePackages.node-gyp
    unstable.deno
    unstable.bun
  ];
}

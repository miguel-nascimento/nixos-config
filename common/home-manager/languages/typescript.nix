{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    unstable.nodePackages.pnpm
    openssl
    nodejs_20
    nodePackages.node-gyp
    unstable.deno
    unstable.bun
    prettierd
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    nodePackages.pnpm
    openssl
    nodejs_20
    nodePackages.node-gyp
    unstable.deno
    unstable.bun
    prettierd
  ];
}

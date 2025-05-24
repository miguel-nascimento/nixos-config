{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    unstable.nodePackages.pnpm
    unstable.openssl
    unstable.nodejs_20
    unstable.nodePackages.node-gyp
    unstable.deno
    unstable.bun
    unstable.prettierd
  ];
}

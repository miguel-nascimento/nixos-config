{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    unstable.nodePackages.pnpm
    unstable.openssl
    unstable.nodejs_latest
    unstable.nodePackages.node-gyp
    unstable.deno
    staging.bun
    unstable.prettierd
  ];
}

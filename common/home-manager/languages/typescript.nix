{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    unstable.pnpm
    unstable.openssl
    unstable.nodejs_latest
    unstable.node-gyp
    unstable.deno
    staging.bun
    unstable.oxlint
    unstable.oxfmt
  ];
}

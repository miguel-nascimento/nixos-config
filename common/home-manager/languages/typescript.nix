{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.yarn-berry
    unstable.pnpm
    unstable.openssl
    unstable.nodejs_latest
    unstable.typescript_5 # typescript-tools requires the JavaScript tsserver
    unstable.node-gyp
    unstable.deno
    staging.bun
    unstable.oxlint
    unstable.oxfmt
  ];
}

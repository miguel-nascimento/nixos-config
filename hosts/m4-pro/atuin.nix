# Atuin's sync server, so shell history syncs through the house instead of
# api.atuin.sh. Caddy serves it at https://atuin.miguelnascimento.dev
# (caddy.nix), reachable at home and, away, through the router's subnet route.
# The history is end-to-end encrypted by the clients; the server only stores it.
{ pkgs, user, ... }:
let
  data = "/Users/${user}/.local/share/atuin-server";
  start = pkgs.writeShellScript "atuin-server" ''
    mkdir -p ${data}
    # 26.05's atuin (18.15) ships without the server
    exec ${pkgs.unstable.atuin}/bin/atuin-server start
  '';
in
{
  launchd.user.agents.atuin-server.serviceConfig = {
    ProgramArguments = [ "${start}" ];
    EnvironmentVariables = {
      ATUIN_HOST = "127.0.0.1";
      ATUIN_PORT = "8888";
      ATUIN_DB_URI = "sqlite://${data}/atuin.db";
      # Only the LAN and the tailnet reach it; close it once every Mac has an account
      ATUIN_OPEN_REGISTRATION = "true";
    };
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "/Users/${user}/Library/Logs/atuin-server.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/atuin-server.log";
  };
}

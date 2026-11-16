# CLIProxyAPI: an OpenAI/Claude/Gemini-compatible API in front of the
# subscriptions logged in on this Mac (Claude, Codex, Gemini...). Listens on
# 127.0.0.1:8317 only.
#
# The first start writes ~/.cli-proxy-api/config.yaml with a random API key
# (kept there, never in this repo); edit it freely, later starts leave it alone.
# Log in to a provider with, e.g.:
#   cliproxyapi -config ~/.cli-proxy-api/config.yaml -claude-login -no-browser
# (also -codex-login, -login for Gemini); the tokens land in ~/.cli-proxy-api.
{ pkgs, user, ... }:
let
  dir = "/Users/${user}/.cli-proxy-api";
  # 26.05 has no cliproxyapi
  cliproxyapi = pkgs.unstable.cliproxyapi;
  start = pkgs.writeShellScript "cliproxyapi" ''
    mkdir -p ${dir}
    chmod 700 ${dir}
    if [ ! -f ${dir}/config.yaml ]; then
      umask 077
      cat > ${dir}/config.yaml <<EOF
    host: "127.0.0.1"
    port: 8317
    auth-dir: "${dir}"
    api-keys:
      - "$(${pkgs.openssl}/bin/openssl rand -hex 24)"
    remote-management:
      allow-remote: false
      secret-key: ""
    debug: false
    EOF
    fi
    exec ${cliproxyapi}/bin/cliproxyapi -config ${dir}/config.yaml
  '';
in
{
  environment.systemPackages = [ cliproxyapi ];

  launchd.user.agents.cliproxyapi.serviceConfig = {
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "/Users/${user}/Library/Logs/cliproxyapi.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/cliproxyapi.log";
  };
}

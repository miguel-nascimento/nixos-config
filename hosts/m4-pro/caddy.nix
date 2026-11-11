# Caddy gives the house services names on miguelnascimento.dev. The DNS records
# point at this Mac's Tailscale IP, so they only work inside the tailnet; the
# certificates come from Let's Encrypt through Cloudflare's DNS (DNS-01), so
# nothing has to be reachable from the internet.
#
# macOS only lets non-root processes bind ports below 1024 on all interfaces,
# so Caddy listens on 127.0.0.1 and Tailscale passes the tailnet's port 443
# through to it as raw TCP (TLS still ends in Caddy, with its certificate).
{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:
let
  tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
  httpsPort = 8443;

  caddy = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
    hash = "sha256-tubXIDCJnO2mvdnPlZclwDhNGaeeYLSt7lnni3+pXDo=";
  };

  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      admin off
      https_port ${toString httpsPort}
      auto_https disable_redirects
    }

    (tailnet) {
      bind 127.0.0.1
      tls {
        dns cloudflare {env.CF_API_TOKEN}
        resolvers 1.1.1.1
      }
    }

    casa.miguelnascimento.dev {
      import tailnet
      reverse_proxy 127.0.0.1:8123
    }
  '';

  start = pkgs.writeShellScript "caddy" ''
    CF_API_TOKEN="$(cat ${config.age.secrets.cloudflare-dns.path})"
    export CF_API_TOKEN
    exec ${caddy}/bin/caddy run --config ${caddyfile} --adapter caddyfile
  '';
in
{
  # Cloudflare API token: Zone Read + DNS Edit on miguelnascimento.dev
  age.secrets.cloudflare-dns = {
    file = "${inputs.self}/secrets/cloudflare-dns.age";
    owner = user;
  };

  launchd.user.agents.caddy.serviceConfig = {
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "/Users/${user}/Library/Logs/caddy.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/caddy.log";
  };

  # The tailnet's https port, passed through untouched to Caddy
  system.userActivation.text = lib.mkAfter ''
    ${tailscale} serve --bg --tcp=443 tcp://127.0.0.1:${toString httpsPort} >/dev/null
  '';
}

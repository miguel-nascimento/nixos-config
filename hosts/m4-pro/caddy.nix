# Caddy gives the house services names on miguelnascimento.dev. The DNS records
# point at this Mac's Tailscale IP, so they only work inside the tailnet; the
# certificates come from Let's Encrypt through Cloudflare's DNS (DNS-01), so
# nothing has to be reachable from the internet.
{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:
let
  # This Mac on the tailnet (tailscale ip -4); Caddy listens only there
  tailscaleIp = "100.69.231.16";

  caddy = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
    hash = "sha256-tubXIDCJnO2mvdnPlZclwDhNGaeeYLSt7lnni3+pXDo=";
  };

  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      admin off
    }

    (tailnet) {
      bind ${tailscaleIp}
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

  # Until Tailscale is up the bind fails; launchd starts it again
  launchd.user.agents.caddy.serviceConfig = {
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    KeepAlive = true;
    ThrottleInterval = 30;
    StandardOutPath = "/Users/${user}/Library/Logs/caddy.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/caddy.log";
  };
}

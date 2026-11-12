# How the house is reached (full write-up: ~/notes/ax3000t-stock-backup-2026-11-11/
# NETWORKING.md; router side: ~/notes/ax3000t-stock-backup-2026-11-11/setup.sh).
#
# casa.* / executor.* (Caddy) resolve publicly to this Mac's LAN address,
# 192.168.31.207 (pinned in the router's DHCP). At home any device reaches it
# directly, whatever tailnet it runs (a work tailnet claims all of
# 100.64.0.0/10, so tailnet addresses can't work for it). Away, the personal
# tailnet reaches it through the router's subnet route (192.168.31.0/24).
# haproxy takes the LAN's port 443 and hands it to Caddy with the client's
# address (PROXY protocol), so Home Assistant sees who is asking.
#
# The router (AX3000T, always on the personal tailnet) also serves Home
# Assistant at https://ax3000t.tail17d63.ts.net:8123 and the Alexa Funnel
# (:10000), through the socat relay below, which only accepts the router:
# Home Assistant trusts the client IP that the router's Tailscale puts in
# X-Forwarded-For, so nobody else on the LAN may send one.
#
# Root daemons: macOS's Local Network privacy blocks processes run as the user
# without an app behind them from talking to the LAN; root is exempt.
{ pkgs, lib, ... }:
let
  router = "192.168.31.1";
  # name = [ relay port, local port ]
  relays = {
    home-assistant = [
      18123
      8123
    ];
  };
  lanEntry = pkgs.writeText "haproxy.cfg" ''
    global
      maxconn 512
    defaults
      mode tcp
      timeout connect 5s
      timeout client 1h
      timeout server 1h
    frontend lan
      # The LAN address only: Tailscale's own serve holds *:443
      bind 192.168.31.207:443
      tcp-request connection reject unless { src 192.168.31.0/24 }
      default_backend caddy
    backend caddy
      server caddy 127.0.0.1:8443 send-proxy-v2
  '';
in
{
  launchd.daemons = {
    lan-https.serviceConfig = {
      ProgramArguments = [
        "${pkgs.haproxy}/bin/haproxy"
        "-db"
        "-f"
        "${lanEntry}"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardErrorPath = "/var/log/lan-https.log";
    };
  }
  // lib.mapAttrs' (
    name: ports:
    lib.nameValuePair "relay-${name}" {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.socat}/bin/socat"
          "TCP-LISTEN:${toString (lib.elemAt ports 0)},reuseaddr,fork,range=${router}/32"
          "TCP:127.0.0.1:${toString (lib.elemAt ports 1)}"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 10;
        StandardErrorPath = "/var/log/relay-${name}.log";
      };
    }
  ) relays;
}

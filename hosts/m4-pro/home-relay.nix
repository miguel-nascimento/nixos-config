# The house services reach the personal tailnet through the router, not
# through this Mac: the m4 may be signed in to another tailnet (work), while
# the AX3000T (OpenWrt) always sits on miguel-nascimento.github. Its Tailscale
# serves https://ax3000t.tail17d63.ts.net (and casa.miguelnascimento.dev, whose
# DNS record points at it) and forwards to the m4 on the LAN, here.
#
# Home Assistant and Caddy only listen on 127.0.0.1, so these relays carry the
# router's connections in. They only accept the router itself (192.168.31.1):
# Home Assistant trusts the client IP that the router's Tailscale puts in
# X-Forwarded-For, so nobody else on the LAN may send one.
#
# Root daemons: macOS's Local Network privacy blocks processes run as the user
# without an app behind them from talking to the LAN; root is exempt.
#
# Router side (in its tailscaled state, not in Nix; the m4 is pinned to
# 192.168.31.207 in the router's DHCP):
#   tailscale serve  --bg --https=8123 http://192.168.31.207:18123
#   tailscale serve  --bg --tcp=443 --proxy-protocol=2 tcp://192.168.31.207:18443
#   tailscale funnel --bg --https=10000 --set-path=/api/alexa/smart_home \
#     http://192.168.31.207:18123/api/alexa/smart_home
{ pkgs, lib, ... }:
let
  router = "192.168.31.1";
  # name = [ relay port, local port ]
  relays = {
    home-assistant = [ 18123 8123 ];
    caddy = [ 18443 8443 ]; # passes the router's PROXY protocol header to Caddy
  };
in
{
  launchd.daemons = lib.mapAttrs' (
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

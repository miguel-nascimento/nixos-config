# CouchDB for Self-hosted LiveSync (github.com/vrtmrz/obsidian-livesync),
# settings from its docs/setup_own_server.md, served to the tailnet at
# https://miguel-m4.boreray-eel.ts.net:6984 with Tailscale's certificate.
#
# Obsidian on this Mac is a LiveSync client too: it writes what the other
# clients sync into ~/notes, where notes-sync.nix commits it to git.
{ config, inputs, ... }:
let
  tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
in
{
  age.secrets.couchdb-admin = {
    file = "${inputs.self}/secrets/couchdb-admin.age";
    owner = "_couchdb";
  };

  services.couchdb = {
    enable = true;
    adminFile = config.age.secrets.couchdb-admin.path;
    settings = {
      couchdb = {
        single_node = true;
        max_document_size = 50000000;
      };
      chttpd = {
        require_valid_user = true;
        max_http_request_size = 4294967296;
        enable_cors = true;
      };
      chttpd_auth = {
        require_valid_user = true;
        authentication_redirect = "/_utils/session.html";
      };
      httpd = {
        WWW-Authenticate = ''Basic realm="couchdb"'';
        enable_cors = true;
      };
      cors = {
        origins = "app://obsidian.md,capacitor://localhost,http://localhost";
        credentials = true;
        headers = "accept, authorization, content-type, origin, referer";
        methods = "GET, PUT, POST, HEAD, DELETE";
        max_age = 3600;
      };
    };
  };

  # tailscaled keeps serve config across restarts; this just declares it
  system.userActivation.text = ''
    ${tailscale} serve --bg --https=6984 http://127.0.0.1:${toString config.services.couchdb.port} >/dev/null
  '';

  # Obsidian stays open here so LiveSync keeps ~/notes current
  launchd.user.agents.obsidian.serviceConfig = {
    ProgramArguments = [
      "/usr/bin/open"
      "-g"
      "-a"
      "Obsidian"
    ];
    RunAtLoad = true;
  };
}

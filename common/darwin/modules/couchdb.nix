# `services.couchdb.enable` runs CouchDB as a launchd daemon, as its own
# `_couchdb` user, listening on localhost only. The admin login comes from
# `adminFile`, an ini file kept out of the Nix store:
#
#   [admins]
#   <user> = <password>
#
# CouchDB hashes it into `${dataDir}/local.ini` on first start.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.couchdb;
  ini = lib.generators.toINI { };
  settings = pkgs.writeText "couchdb.ini" (
    ini (
      lib.recursiveUpdate {
        couchdb = {
          database_dir = cfg.dataDir;
          view_index_dir = cfg.dataDir;
          uri_file = "${cfg.dataDir}/couch.uri";
        };
        chttpd = {
          bind_address = "127.0.0.1";
          inherit (cfg) port;
        };
      } cfg.settings
    )
  );
  start = pkgs.writeShellScript "couchdb-start" ''
    # At boot the admin secret may land after launchd starts us
    while [ ! -r ${cfg.adminFile} ]; do sleep 1; done
    touch ${cfg.dataDir}/local.ini
    export HOME=${cfg.dataDir}
    export COUCHDB_INI_FILES="${cfg.package}/etc/default.ini ${settings} ${cfg.adminFile} ${cfg.dataDir}/local.ini"
    exec ${cfg.package}/bin/couchdb
  '';
in
{
  options.services.couchdb = {
    enable = lib.mkEnableOption "CouchDB";
    package = lib.mkPackageOption pkgs "couchdb3" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5984;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/couchdb";
    };
    adminFile = lib.mkOption {
      type = lib.types.path;
      description = "Ini file with an `[admins]` section, readable by `_couchdb`.";
    };
    settings = lib.mkOption {
      type = with lib.types; attrsOf (attrsOf (oneOf [ str int bool ]));
      default = { };
      description = "Extra CouchDB ini settings, by section.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.knownGroups = [ "_couchdb" ];
    users.groups._couchdb.gid = 460;
    users.knownUsers = [ "_couchdb" ];
    users.users._couchdb = {
      uid = 460;
      gid = 460;
      home = cfg.dataDir;
      createHome = true;
      shell = "/usr/bin/false";
      isHidden = true;
      description = "CouchDB";
    };

    system.activationScripts.postActivation.text = ''
      mkdir -p ${cfg.dataDir}
      chown -R _couchdb:_couchdb ${cfg.dataDir}
      chmod 700 ${cfg.dataDir}
      touch /var/log/couchdb.log
      chown _couchdb:_couchdb /var/log/couchdb.log
    '';

    launchd.daemons.couchdb.serviceConfig = {
      ProgramArguments = [ "${start}" ];
      UserName = "_couchdb";
      GroupName = "_couchdb";
      WorkingDirectory = cfg.dataDir;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/couchdb.log";
      StandardErrorPath = "/var/log/couchdb.log";
    };
  };
}

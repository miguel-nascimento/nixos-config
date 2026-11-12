# Home Assistant, the nixpkgs package, shaped like NixOS's services.home-assistant
# (wiki.nixos.org/wiki/Home_Assistant). nix-darwin has no such module, so this is
# the small part of it a Mac needs: the package, a declared configuration.yaml
# and a launchd agent. Served to the personal tailnet by the router, at
# https://ax3000t.tail17d63.ts.net:8123 and casa.miguelnascimento.dev (home-relay.nix).
#
# Nix owns configuration.yaml. Everything made in the UI stays editable there:
# dashboards, integrations and devices live in .storage, and automations,
# scenes and scripts in their own yaml files next to it.
{
  pkgs,
  lib,
  inputs,
  user,
  ...
}:
let
  configDir = "/Users/${user}/.homeassistant";
  port = 8123;

  # nixpkgs only marks Home Assistant for Linux, but it builds and runs on macOS
  unsupported = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnsupportedSystem = true;
  };

  # Integrations need their Python packages in the build: Home Assistant
  # can't pip install into the Nix store. Add one here before setting it up in the UI.
  extraComponents = [
    "alexa"
    "analytics"
    "backup"
    "bluetooth"
    "google_translate"
    "isal"
    "met"
    "mqtt"
    "radio_browser"
    "shopping_list"
    "sun"
    "switch_as_x"
  ];

  # Not in Home Assistant itself: linked into custom_components at start, with
  # their Python packages added to the build below
  customComponents = [ unsupported.home-assistant-custom-components.adaptive_lighting ];

  package =
    (unsupported.home-assistant.override {
      inherit extraComponents;
      # default_config's packages, but Matter's needs Linux-only CHIP builds
      extraPackages =
        ps:
        lib.filter (p: !lib.hasPrefix "matter" (p.pname or "")) (
          unsupported.home-assistant.getPackages "default_config" ps
        )
        ++ lib.concatMap (c: c.dependencies or c.propagatedBuildInputs or [ ]) customComponents;
      packageOverrides = _: super: {
        # Their tests hang, need Linux (inotify) or time out on macOS
        snitun = super.snitun.overridePythonAttrs { doCheck = false; };
        asyncinotify = super.asyncinotify.overridePythonAttrs { doCheck = false; };
        serialx = super.serialx.overridePythonAttrs { doCheck = false; };
        gpiozero = super.gpiozero.overridePythonAttrs { doCheck = false; };
      };
    }).overridePythonAttrs
      {
        # Its test suite takes longer than the build and covers Linux
        doCheck = false;
        doInstallCheck = false;
      };

  config = {
    # Name, location and units are set in the UI (Settings → System → General)
    default_config = { };
    # No login at home: any device on the personal tailnet or the house's
    # Wi-Fi signs straight in as miguel. Elsewhere (Alexa's token) the
    # password login stays.
    # IPv4 only: the Funnel ingress nodes use fd7a:115c:a1e0::/48 addresses.
    # HA only listens on 127.0.0.1 and takes the client IP from
    # X-Forwarded-For, set by the router's tailscale serve (:8123) and Caddy
    # (casa.*), through the relays in home-relay.nix.
    homeassistant.auth_providers =
      let
        # The personal tailnet and the house's LAN (casa.* from home Wi-Fi,
        # through the LAN relay in home-relay.nix)
        trusted = [
          "100.64.0.0/10"
          "192.168.31.0/24"
        ];
      in
      [
        {
          type = "trusted_networks";
          trusted_networks = trusted;
          trusted_users = lib.genAttrs trusted (_: [ "8cd4a9921c6d474eaed9002f5ef71a05" ]); # miguel
          allow_bypass_login = true;
        }
        { type = "homeassistant"; }
      ];
    # Network settings live in the UI (Settings → System → Network) since 2026.10:
    # listen on 127.0.0.1 only and trust it as a proxy, for the relays
    "automation ui" = "!include automations.yaml";
    "scene ui" = "!include scenes.yaml";
    "script ui" = "!include scripts.yaml";
    # Adaptive Lighting with its defaults: the spots follow the sun, white
    # and full by day, ramping to warm and dim towards solar midnight. A
    # color set by hand wins until the spot is turned off. Its switches are
    # switch.adaptive_lighting_*_spots.
    adaptive_lighting = [
      {
        name = "Spots";
        # The Zigbee group of all six bulbs: one groupcast keeps them on the
        # same color however they were turned on (Todos os Spots, Todas as
        # luzes, Spot Mesa/Lazer or the bed switch)
        lights = [ "light.todos_os_spots" ];
      }
    ];
    # Lights only, and not the Tecla Cama relays: they feed the spots, and the
    # spot groups already switch them on when needed
    alexa.smart_home = {
      locale = "pt-BR";
      filter = {
        include_domains = [ "light" ];
        include_entities = [ "script.spots_cor_automatica" ];
        exclude_entities = [
          "light.hobeian_zg_301z_2ch_luz"
          "light.hobeian_zg_301z_2ch_luz_2"
        ];
      };
      # "Alexa, ativar cor automática": spots back on Adaptive Lighting
      entity_config."script.spots_cor_automatica" = {
        name = "Cor automática";
        display_categories = "SCENE_TRIGGER";
      };
    };
  };

  # Same trick as the NixOS module: unquote the !include tags
  configFile = pkgs.runCommand "configuration.yaml" { } ''
    cp ${(pkgs.formats.yaml { }).generate "configuration.yaml" config} $out
    sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
  '';

  start = pkgs.writeShellScript "home-assistant" ''
    mkdir -p ${configDir}/custom_components
    ${lib.concatMapStrings (c: ''
      for d in ${c}/custom_components/*; do ln -sfn "$d" ${configDir}/custom_components/; done
    '') customComponents}
    ln -sf ${configFile} ${configDir}/configuration.yaml
    for f in automations scenes scripts; do
      [ -s ${configDir}/$f.yaml ] || echo '[]' > ${configDir}/$f.yaml
    done
    exec ${package}/bin/hass --config ${configDir}
  '';
in
{
  imports = [ ./home-relay.nix ];

  environment.systemPackages = [ package ];

  # Starts with the user, like Obsidian and notes-sync
  launchd.user.agents.home-assistant.serviceConfig = {
    ProgramArguments = [ "${start}" ];
    # The integrations' Python packages, as NixOS's module passes them
    EnvironmentVariables.PYTHONPATH = package.pythonPath;
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "/Users/${user}/Library/Logs/home-assistant.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/home-assistant.log";
  };

  # Snapshots the HA and Zigbee2MQTT config into the private repo ~/ha
  # (github.com/miguel-nascimento/ha) every hour, so a clone restores the house
  launchd.user.agents.ha-backup.serviceConfig = {
    ProgramArguments = [
      "${pkgs.bash}/bin/bash"
      "/Users/${user}/ha/backup.sh"
    ];
    # Apple's ssh (/usr/bin) is the one that unlocks the key from the Keychain
    EnvironmentVariables.PATH =
      lib.makeBinPath [
        pkgs.git
        pkgs.rsync
        pkgs.coreutils
        pkgs.age
      ]
      + ":/usr/bin:/bin";
    StartInterval = 3600;
    StandardOutPath = "/Users/${user}/Library/Logs/ha-backup.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/ha-backup.log";
  };

}

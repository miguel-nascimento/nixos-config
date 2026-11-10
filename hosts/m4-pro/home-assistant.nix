# Home Assistant, the nixpkgs package, shaped like NixOS's services.home-assistant
# (wiki.nixos.org/wiki/Home_Assistant). nix-darwin has no such module, so this is
# the small part of it a Mac needs: the package, a declared configuration.yaml
# and a launchd agent. Served to the tailnet at https://miguel-m4.boreray-eel.ts.net:8123.
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
  tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

  # nixpkgs only marks Home Assistant for Linux, but it builds and runs on macOS
  unsupported = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnsupportedSystem = true;
  };

  # Integrations need their Python packages in the build: Home Assistant
  # can't pip install into the Nix store. Add one here before setting it up in the UI.
  extraComponents = [
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

  package =
    (unsupported.home-assistant.override {
      inherit extraComponents;
      # default_config's packages, but Matter's needs Linux-only CHIP builds
      extraPackages =
        ps:
        lib.filter (p: !lib.hasPrefix "matter" (p.pname or "")) (
          unsupported.home-assistant.getPackages "default_config" ps
        );
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
    # Network settings live in the UI (Settings → System → Network) since 2026.10:
    # listen on 127.0.0.1 only and trust it as a proxy, for tailscale serve
    "automation ui" = "!include automations.yaml";
    "scene ui" = "!include scenes.yaml";
    "script ui" = "!include scripts.yaml";
  };

  # Same trick as the NixOS module: unquote the !include tags
  configFile = pkgs.runCommand "configuration.yaml" { } ''
    cp ${(pkgs.formats.yaml { }).generate "configuration.yaml" config} $out
    sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
  '';

  start = pkgs.writeShellScript "home-assistant" ''
    mkdir -p ${configDir}
    ln -sf ${configFile} ${configDir}/configuration.yaml
    for f in automations scenes scripts; do
      [ -s ${configDir}/$f.yaml ] || echo '[]' > ${configDir}/$f.yaml
    done
    exec ${package}/bin/hass --config ${configDir}
  '';
in
{
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

  system.userActivation.text = lib.mkAfter ''
    ${tailscale} serve --bg --https=${toString port} http://127.0.0.1:${toString port} >/dev/null
  '';
}

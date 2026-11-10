# Zigbee for Home Assistant: Zigbee2MQTT on the SMLIGHT SLZB-06Mu (USB, EmberZNet 8),
# talking to Home Assistant through a local Mosquitto. Both run as launchd agents,
# like Home Assistant. The Zigbee2MQTT UI is at https://miguel-m4.boreray-eel.ts.net:8124.
#
# Zigbee2MQTT keeps its configuration.yaml in its data directory, because its UI
# writes to it (device names, groups, options) and because it holds the network key.
# Nix only pins what has to match this machine, through ZIGBEE2MQTT_CONFIG_* variables.
# Without that file it refuses to start instead of forming a new network, which
# would mean pairing every device again. A copy lives in ~/Backups.
{ pkgs, user, ... }:
let
  home = "/Users/${user}";
  dataDir = "${home}/.zigbee2mqtt";
  mqttPort = 1883;
  frontendPort = 8099;
  tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

  mosquittoConf = pkgs.writeText "mosquitto.conf" ''
    listener ${toString mqttPort} 127.0.0.1
    allow_anonymous true
    persistence true
    persistence_location ${home}/.mosquitto/
  '';

  mosquitto = pkgs.writeShellScript "mosquitto" ''
    mkdir -p ${home}/.mosquitto
    exec ${pkgs.unstable.mosquitto}/bin/mosquitto -c ${mosquittoConf}
  '';

  zigbee2mqtt = pkgs.writeShellScript "zigbee2mqtt" ''
    if [ ! -f ${dataDir}/configuration.yaml ]; then
      echo "zigbee2mqtt: ${dataDir}/configuration.yaml is missing; restore it from ~/Backups" >&2
      exit 1
    fi
    exec ${pkgs.unstable.zigbee2mqtt}/bin/zigbee2mqtt
  '';

  logs = name: {
    StandardOutPath = "${home}/Library/Logs/${name}.log";
    StandardErrorPath = "${home}/Library/Logs/${name}.log";
  };
in
{
  environment.systemPackages = [ pkgs.unstable.mosquitto ];

  launchd.user.agents.mosquitto.serviceConfig = {
    ProgramArguments = [ "${mosquitto}" ];
    RunAtLoad = true;
    KeepAlive = true;
  }
  // logs "mosquitto";

  launchd.user.agents.zigbee2mqtt.serviceConfig = {
    ProgramArguments = [ "${zigbee2mqtt}" ];
    RunAtLoad = true;
    KeepAlive = true;
    EnvironmentVariables = {
      ZIGBEE2MQTT_DATA = dataDir;
      ZIGBEE2MQTT_CONFIG_SERIAL_PORT = "/dev/cu.usbmodem2101";
      ZIGBEE2MQTT_CONFIG_SERIAL_ADAPTER = "ember";
      ZIGBEE2MQTT_CONFIG_SERIAL_BAUDRATE = "115200";
      ZIGBEE2MQTT_CONFIG_SERIAL_RTSCTS = "false";
      ZIGBEE2MQTT_CONFIG_MQTT_SERVER = "mqtt://127.0.0.1:${toString mqttPort}";
      ZIGBEE2MQTT_CONFIG_FRONTEND_ENABLED = "true";
      ZIGBEE2MQTT_CONFIG_FRONTEND_HOST = "127.0.0.1";
      ZIGBEE2MQTT_CONFIG_FRONTEND_PORT = toString frontendPort;
      ZIGBEE2MQTT_CONFIG_HOMEASSISTANT_ENABLED = "true";
    };
  }
  // logs "zigbee2mqtt";

  system.userActivation.text = ''
    ${tailscale} serve --bg --https=8124 http://127.0.0.1:${toString frontendPort} >/dev/null
  '';
}

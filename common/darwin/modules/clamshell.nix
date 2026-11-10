# `power.clamshell = true;` keeps a MacBook awake with the lid closed and no
# display attached, so it can sit in a corner as a server. Replaces Amphetamine.
{ config, lib, ... }:
{
  options.power.clamshell = lib.mkEnableOption "staying awake with the lid closed";

  config = lib.mkIf config.power.clamshell {
    power.sleep.computer = "never";
    power.restartAfterFreeze = true;
    system.activationScripts.postActivation.text = ''
      pmset -a disablesleep 1 tcpkeepalive 1 womp 1 powernap 0 standby 0 hibernatemode 0
    '';
  };
}

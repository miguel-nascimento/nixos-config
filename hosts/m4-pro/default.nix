# The home server: lid closed in a corner, reached over Tailscale.
# Everything it serves sits behind `tailscale serve`, never on the LAN.
{ inputs, ... }:
{
  imports = [
    inputs.agenix.darwinModules.default
    ./obsidian-livesync.nix
    ./notes-sync.nix
    ./home-assistant.nix
  ];

  power.clamshell = true;
  power.sleep.display = 10;
}

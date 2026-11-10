# Small options of our own, so the Mac configs read as settings, not scripts
{
  imports = [
    ./user-activation.nix
    ./raycast.nix
    ./trackpad.nix
    ./openssh.nix
    ./couchdb.nix
    ./clamshell.nix
  ];
}

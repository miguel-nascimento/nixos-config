# `services.openssh.keysOnly = true;` turns off password logins for Remote Login.
{ config, lib, ... }:
{
  options.services.openssh.keysOnly = lib.mkEnableOption "SSH logins with keys only, never passwords";

  config.services.openssh.extraConfig = lib.mkIf config.services.openssh.keysOnly ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';
}

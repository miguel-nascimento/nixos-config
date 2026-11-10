# `system.userActivation.text` runs as the primary user at the end of every
# switch, for per-user settings nix-darwin has no option for. System Settings
# picks the changes up right after, without logging out.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.system) primaryUser;
  script = pkgs.writeShellScript "user-activation" ''
    ${config.system.userActivation.text}
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
in
{
  options.system.userActivation.text = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Shell commands run as `system.primaryUser` at the end of activation.";
  };

  config.system.activationScripts.postActivation.text =
    lib.mkIf (config.system.userActivation.text != "")
      ''
        launchctl asuser "$(id -u -- ${primaryUser})" sudo --user=${primaryUser} -- ${script}
      '';
}

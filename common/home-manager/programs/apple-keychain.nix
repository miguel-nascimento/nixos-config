# `programs.ssh.useAppleKeychain = true;` keeps the SSH key's passphrase in the
# macOS login Keychain, so ssh and git signing never prompt, even from shells
# with no terminal (agents, editors, launchd jobs).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  ssh-keygen = "${pkgs.openssh}/bin/ssh-keygen";

  # git signs through this: if the agent lost the key it reloads it from the
  # Keychain, and stdin is /dev/null so a missing key fails at once instead of
  # ssh-keygen reading a passphrase from an agent's open stdin pipe forever.
  # A real terminal still prompts on /dev/tty. Verification passes payloads on
  # stdin, so only `-Y sign` is redirected.
  signer = pkgs.writeShellScript "ssh-keygen-sign" ''
    if [ "$1" = -Y ] && [ "$2" = sign ]; then
      /usr/bin/ssh-add -l >/dev/null 2>&1 ||
        /usr/bin/ssh-add --apple-load-keychain -q </dev/null >/dev/null 2>&1
      exec ${ssh-keygen} "$@" </dev/null
    fi
    exec ${ssh-keygen} "$@"
  '';
in
{
  options.programs.ssh.useAppleKeychain = lib.mkEnableOption "" // {
    description = ''
      Keep SSH key passphrases in the macOS login Keychain. Keys are loaded into
      launchd's ssh-agent at login, ssh adds them back to the Keychain on first
      use, and git's SSH signing reloads them instead of hanging without a TTY.
    '';
  };

  config = lib.mkIf config.programs.ssh.useAppleKeychain {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "programs.ssh.useAppleKeychain only works on macOS.";
      }
    ];

    programs.ssh.settings."*" = {
      AddKeysToAgent = "yes";
      # UseKeychain is Apple-only; nix's ssh would reject the config without this
      IgnoreUnknown = "UseKeychain";
      UseKeychain = "yes";
    };

    # launchd's ssh-agent (SSH_AUTH_SOCK, inherited by every shell and GUI app)
    # gets the Keychain's keys at login
    launchd.agents.ssh-add-keychain = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/ssh-add"
          "--apple-load-keychain"
          "-q"
        ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/ssh-add-keychain.log";
      };
    };

    programs.git.signing.signer = lib.mkIf (config.programs.git.signing.format == "ssh") (
      toString signer
    );
  };
}

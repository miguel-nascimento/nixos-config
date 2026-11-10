{ user, ... }:
{
  imports = [ ./modules ];

  # Determinate Nix manages the nix daemon and nix.conf
  nix.enable = false;

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6Bo70dehaX/OYMz094D35auxz5G0rdqf/tUj6ICn4a miguel-nascimento"
    ];
  };

  # Remote Login, key only, so the Macs can ssh/rsync to each other over Tailscale
  services.openssh = {
    enable = true;
    keysOnly = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.trackpad.tapToClick = true;

  programs.raycast = {
    enable = true;
    replaceSpotlight = true;
  };

  # Homebrew itself, installed and pinned by nix
  nix-homebrew = {
    enable = true;
    inherit user;
  };

  # GUI apps as normal /Applications apps, so they keep updating themselves
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";
    casks = [
      "arc"
      "bitwarden"
      "discord"
      "ghostty"
      "granola"
      "iina"
      "linear"
      "notion-calendar"
      "obsidian"
      "orbstack"
      "slack"
      "tailscale-app"
      "transmission"
      "jordanbaird-ice"
    ];
  };

  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.stateVersion
  system.stateVersion = 6;
}

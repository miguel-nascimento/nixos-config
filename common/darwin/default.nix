{ outputs, user, ... }:
{
  # Determinate Nix manages the nix daemon and nix.conf
  nix.enable = false;

  nixpkgs = {
    overlays = [ outputs.overlays.unstable-packages ];
    config.allowUnfree = true;
  };

  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Tap to click; postActivation also sets it where System Settings looks
  system.defaults.trackpad.Clicking = true;

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
      "iina"
      "linear"
      "notion-calendar"
      "obsidian"
      "orbstack"
      "raycast"
      "slack"
      "tailscale-app"
    ];
  };

  # ⌘Space opens Raycast instead of Spotlight
  system.defaults.CustomUserPreferences."com.raycast.macos".raycastGlobalHotkey = "Command-49";
  # -dict-add changes only Spotlight's shortcut (64), not the others; activateSettings applies it without a re-login
  system.activationScripts.postActivation.text = ''
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
      -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.stateVersion
  system.stateVersion = 6;
}

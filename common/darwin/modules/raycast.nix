# `programs.raycast.enable` installs Raycast; `replaceSpotlight` hands it ⌘Space.
{ config, lib, ... }:
let
  cfg = config.programs.raycast;
in
{
  options.programs.raycast = {
    enable = lib.mkEnableOption "Raycast, installed as a Homebrew cask";
    replaceSpotlight = lib.mkEnableOption "⌘Space opening Raycast instead of Spotlight";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { homebrew.casks = [ "raycast" ]; }

      (lib.mkIf cfg.replaceSpotlight {
        system.defaults.CustomUserPreferences."com.raycast.macos".raycastGlobalHotkey = "Command-49";
        # 64 is Spotlight's shortcut (⌘Space, turned off); -dict-add leaves the others alone
        system.userActivation.text = ''
          /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
            "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
        '';
      })
    ]
  );
}

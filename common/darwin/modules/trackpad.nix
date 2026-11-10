# `system.trackpad.tapToClick = true;`
{ config, lib, ... }:
{
  options.system.trackpad.tapToClick = lib.mkEnableOption "tap to click";

  config = lib.mkIf config.system.trackpad.tapToClick {
    system.defaults.trackpad.Clicking = true;
    # System Settings reads this per-host key, not the trackpad domain
    system.userActivation.text = ''
      /usr/bin/defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    '';
  };
}

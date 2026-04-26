{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
  };
}

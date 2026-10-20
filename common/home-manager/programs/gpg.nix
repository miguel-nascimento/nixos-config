{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    # Cache passphrases for 8h (max 24h) to avoid prompts stalling commits
    defaultCacheTtl = 28800;
    maxCacheTtl = 86400;
    pinentry.package = pkgs.pinentry-curses;
  };
}

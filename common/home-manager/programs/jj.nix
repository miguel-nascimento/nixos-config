{ pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    package = pkgs.unstable.jujutsu;
    settings = {
      ui = {
        pager = "delta";
        diff = {
          format = "git";
        };
      };
    };
  };
}

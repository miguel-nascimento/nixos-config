{ pkgs, ... }:
{
  home.packages = [ pkgs.unstable.git-wt ];

  programs.git = {
    enable = true;

    lfs.enable = true;

    settings.alias = {
      cm = "commit -m";
      sw = "switch";
      lg = "log --format='%Cred%h%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset%C(yellow)%d%Creset' --no-merges";
    };

    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;

      # Worktree configuration
      fetch.prune = true; # Automatically prune deleted remote branches
      worktree.guessRemote = true; # Auto-setup tracking for new worktrees

      # Rerere configuration
      rerere.enabled = true;
      rerere.autoUpdate = true;
    };

    settings.user.email = "miguelgomes13@live.com";
    settings.user.name = "Miguel Nascimento";

    signing = {
      key = "3C5F43ADECC84547";
      signByDefault = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      detect-dark-light = "auto";
      dark-syntax-theme = "GitHub";
      light-syntax-theme = "GitHub";
    };
  };

  programs.gh = {
    enable = true;
  };
}

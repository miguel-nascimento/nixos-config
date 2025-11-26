_: {
  programs.git = {
    enable = true;

    aliases = {
      cm = "commit -m";
      sw = "switch";
      lg = "log --format='%Cred%h%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset%C(yellow)%d%Creset' --no-merges";
    };

    delta = {
      enable = true;
      options.side-by-side = true;
    };

    extraConfig = {
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

    userEmail = "miguelgomes13@live.com";
    userName = "Miguel Nascimento";
  };

  programs.gh = {
    enable = true;
  };
}

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

      # Speed up status in repos with many files/worktrees
      core.fsmonitor = pkgs.stdenv.isDarwin; # builtin daemon is macOS/Windows only
      core.untrackedCache = true;
      feature.manyFiles = true;

      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
    };

    settings.user.email = "miguelgomes13@live.com";
    settings.user.name = "Miguel Nascimento";

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
  };

  xdg.configFile."git/allowed_signers".text = ''
    miguelgomes13@live.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6Bo70dehaX/OYMz094D35auxz5G0rdqf/tUj6ICn4a
  '';

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

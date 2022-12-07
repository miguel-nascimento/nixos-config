_:
{
  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [ "--height 40%" "--preview 'bat --color=always {}'"];
  };
}
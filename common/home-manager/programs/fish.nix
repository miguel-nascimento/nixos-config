_:
{
  programs.fish = {
    enable = true;
    # shellInit = ''
    #   # brew hack, im lazy
    #   export PATH="/opt/homebrew/bin:$PATH"
    #   export PATH="/Users/miguel/.local/bin:$PATH"
    # '';
    # TODO: add colorscheme mono smoke here
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      ls = "eza";
      cat = "bat";
    };
  };
}

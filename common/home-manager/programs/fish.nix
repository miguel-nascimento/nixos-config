# Note on M1:
# Since I'm not using nix-darwin, need to set the default using
# $(which fish) >> /etc/shells
# chsh -s $(which fish)
# to change the default shell
# Also, install fisher and nix-env.fish
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

_:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    initExtra = ''
      bindkey -M emacs "^[[3;5~" kill-word
      bindkey -M emacs "^H" backward-kill-word
      bindkey "''${key[Up]}" up-line-or-search
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char
    '';

    enableCompletion = true;
    enableAutosuggestions = true;
    autocd = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "z" ];
    };
  };
}
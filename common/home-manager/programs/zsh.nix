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
      export TERM=xterm-256color
    '';
      #VSCODE_IPC_HOOK_CLI=$( lsof | grep $UID/vscode-ipc | awk '{print $(NF-1)}' | head -n 1 )

    enableCompletion = true;
    enableAutosuggestions = true;
    autocd = true;
  };
}

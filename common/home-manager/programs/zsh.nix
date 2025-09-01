_: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initContent = ''
      bindkey -M emacs "^[[3;5~" kill-word
      bindkey -M emacs "^H" backward-kill-word
      bindkey "''${key[Up]}" up-line-or-search
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char
      export TERM=xterm-256color

      # brew hack, im lazy
      export PATH="/opt/homebrew/bin:$PATH"
      export PATH="/Users/miguel/.local/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
    '';
    #VSCODE_IPC_HOOK_CLI=$( lsof | grep $UID/vscode-ipc | awk '{print $(NF-1)}' | head -n 1 )
    envExtra = ''
      export PATH="/Users/miguel/.foundry/bin:$PATH"
    '';

    shellAliases = {
      ls = "eza";
      cat = "bat";
    };
    enableCompletion = true;
    autosuggestion.enable = true;
    autocd = true;
  };
}

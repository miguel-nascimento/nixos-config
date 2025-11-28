_: {
  # Suppress "Last login:" message on macOS
  home.file.".hushlogin".text = "";

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

      # GitHub PR helper function
      gpr() {
        # Store current branch
        local original_branch=$(git branch --show-current)

        # Get latest commit hash
        local commit_hash=$(git rev-parse HEAD)
        local commit_short_hash=$(git rev-parse --short HEAD)

        # Stash changes including untracked files
        echo "Stashing changes..."
        git stash -u

        # Determine base branch (try main, then master)
        local base_branch="main"
        if ! git show-ref --verify --quiet refs/heads/main; then
          base_branch="master"
        fi

        # Create new branch from base
        local new_branch="miguel/$commit_short_hash"
        echo "Creating branch $new_branch from $base_branch..."
        git checkout -b "$new_branch" "$base_branch"

        # Cherry-pick the commit
        echo "Cherry-picking commit $commit_short_hash..."
        if ! git cherry-pick "$commit_hash"; then
          echo "Cherry-pick failed. Aborting..."
          git cherry-pick --abort
          git checkout "$original_branch"
          git stash pop
          return 1
        fi

        # Push the branch
        echo "Pushing branch $new_branch..."
        if ! git push -u origin "$new_branch"; then
          echo "Push failed. Cleaning up..."
          git checkout "$original_branch"
          git branch -D "$new_branch"
          git stash pop
          return 1
        fi

        # Go back to original branch
        echo "Returning to $original_branch..."
        git checkout "$original_branch"

        # Apply stash
        echo "Applying stash..."
        git stash pop

        # Open PR in web
        echo "Opening PR in browser..."
        gh pr create --web --head "$new_branch"
      }
    '';
    #VSCODE_IPC_HOOK_CLI=$( lsof | grep $UID/vscode-ipc | awk '{print $(NF-1)}' | head -n 1 )
    envExtra = ''
      export PATH="/Users/miguel/.foundry/bin:$PATH"
      export NIXPKGS_ALLOW_UNFREE=1
    '';

    shellAliases = {
      ls = "eza";
      cat = "bat";
      claude = "bunx @anthropic-ai/claude-code";
      codex = "bunx @openai/codex";
    };
    enableCompletion = true;
    completionInit = ''
      # Only regenerate .zcompdump once per day (saves ~200ms)
      autoload -Uz compinit
      () {
        setopt local_options extendedglob
        local zcd=~/.config/zsh/.zcompdump
        if [[ -f "$zcd" && ! "$zcd"(#qN.mh+24) ]]; then
          compinit -C -d "$zcd"
        else
          compinit -d "$zcd"
        fi
      }
    '';
    autosuggestion.enable = true;
    autocd = true;
  };
}

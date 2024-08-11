{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    shortcut = "a";
    baseIndex = 1; # 0 is very far

    # TODO: ressurect, fingers, continuum?
    plugins = with pkgs; [
      { 
        # btw nixpkgs catppuccin is outdated :D
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'macchiato'
          set -g @catppuccin_window_right_separator "█ "
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_middle_separator " | "

          set -g @catppuccin_window_default_fill "none"
          set -g @catppuccin_window_current_fill "all"

          set -g @catppuccin_status_modules_right "application date_time"
          set -g @catppuccin_status_left_separator "|"
          set -g @catppuccin_status_right_separator "█"

          set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M:%S"
        '';
      }
      { plugin = tmuxPlugins.vim-tmux-navigator; }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
    extraConfig = ''
      set -g default-terminal "screen-256color"
      set-option -sa terminal-overrides ",xterm-256color:RGB"

      set -g visual-bell on
      bind V copy-mode
      bind -T copy-mode-vi V send-keys -X cancel

      unbind -T copy-mode-vi v

      bind -T copy-mode-vi v \
      send-keys -X begin-selection

      bind -T copy-mode-vi 'C-v' \
      send-keys -X rectangle-toggle

      bind -T copy-mode-vi y \
      send-keys -X copy-pipe-and-cancel "pbcopy"

      bind -T copy-mode-vi MouseDragEnd1Pane \
      send-keys -X copy-pipe-and-cancel "pbcopy"

      set-option -g renumber-windows on
    '';
  };
}

{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    shortcut = "a";
    baseIndex = 1; # 0 is very far

    plugins = with pkgs; [
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
      set -g default-terminal "tmux-256color"
      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -as terminal-features ",xterm-ghostty:RGB:extkeys"
      set -as terminal-overrides ",xterm-ghostty:Tc"

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

      # Put the status bar at the bottom and force a full gray palette.
      set -g status-position bottom
      set -g status-style "bg=#2b2b2b,fg=#c9c9c9"
      set -g message-style "bg=#3a3a3a,fg=#e6e6e6"
      set -g message-command-style "bg=#3a3a3a,fg=#e6e6e6"
      set -g mode-style "bg=#5a5a5a,fg=#f5f5f5"
      set -g pane-border-style "fg=#4a4a4a"
      set -g pane-active-border-style "fg=#8a8a8a"
      set -g status-left-style "bg=#2b2b2b,fg=#c9c9c9"
      set -g status-right-style "bg=#2b2b2b,fg=#c9c9c9"
      set -g window-status-style "bg=#2b2b2b,fg=#9a9a9a"
      set -g window-status-current-style "bg=#444444,fg=#f0f0f0,bold"
      set -g window-status-format " #[bg=#2b2b2b,fg=#9a9a9a]#I:#W #[default]"
      set -g window-status-current-format " #[bg=#444444,fg=#f0f0f0,bold]#I:#W #[default]"
      set -g status-left ""
      set -g status-right ""

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}

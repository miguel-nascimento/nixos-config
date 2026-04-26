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

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}

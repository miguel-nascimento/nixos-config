_:
{
  programs.tmux = {
    enable = true;
    
    mouse = true;
    shortcut = "a";
    extraConfig = ''
      set -g status-right ' #{?client_prefix,#[reverse]<Prefix>#[noreverse] ,}"#{=21:pane_title}" %H:%M %d-%B-%Y'
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # --> Catppuccin (Macchiato)
      thm_bg="#24273a"
      thm_fg="#cad3f5"
      thm_cyan="#91d7e3"
      thm_black="#1e2030"
      thm_gray="#363a4f"
      thm_magenta="#c6a0f6"
      thm_pink="#f5bde6"
      thm_red="#ed8796"
      thm_green="#a6da95"
      thm_yellow="#eed49f"
      thm_blue="#8aadf4"
      thm_orange="#f5a97f"
      thm_black4="#5b6078"
    '';
  };
}

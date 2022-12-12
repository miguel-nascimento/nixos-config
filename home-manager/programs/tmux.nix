_:
{
  programs.tmux = {
    enable = true;

    shortcut = "a";
    extraConfig = ''
      set -g status-right ' #{?client_prefix,#[reverse]<Prefix>#[noreverse] ,}"#{=21:pane_title}" %H:%M %d-%B-%Y'
    '';
  };
}

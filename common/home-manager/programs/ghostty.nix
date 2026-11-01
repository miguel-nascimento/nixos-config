_: {
  programs.ghostty = {
    enable = true;
    # Ghostty itself is the Homebrew cask in common/darwin
    package = null;
    settings = {
      theme = "dark:Github Dark Default,light:Github Light Default";
      font-family = "Berkeley Mono";
      font-thicken = true;
      font-thicken-strength = 50;
      adjust-cell-height = "8%";
      auto-update-channel = "tip";
      keybind = [
        # tmux+vim ctrl+w like splits
        "ctrl+a>v=new_split:right"
        "ctrl+a>s=new_split:down"
        # vim tmux split navigations
        "ctrl+a>h=goto_split:left"
        "ctrl+a>j=goto_split:bottom"
        "ctrl+a>k=goto_split:top"
        "ctrl+a>l=goto_split:right"
        "shift+enter=text:\\n"
      ];
    };
  };
}

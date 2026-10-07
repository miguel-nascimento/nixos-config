_: {
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim-remote";
      gui.showIcons = true;
      git.pagers = [
        {
          colorArgs = "always";
          pager = "delta --paging=never --commit-style box --light";
        }
      ];
    };
  };
}

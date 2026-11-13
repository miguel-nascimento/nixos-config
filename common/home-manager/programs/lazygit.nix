_: {
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim-remote";
      gui.showIcons = true;
      git.diffRenderers = [
        {
          colorArgs = "always";
          command = "delta --paging=never --commit-style box --light";
        }
      ];
    };
  };
}

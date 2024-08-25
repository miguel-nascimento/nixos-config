_:
{
  programs.lazygit = {
    enable = true;
    settings = {
        gui.showIcons = true;
        git.paging = {
            colorArgs = "always";
            pager = "delta --paging=never --commit-style box";
        };
    };
  };
}

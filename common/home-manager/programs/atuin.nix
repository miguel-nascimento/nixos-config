_: {
  # TODO: run a atuin server in home-server
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];
  };
}

_: {
  programs.atuin = {
    enable = true;
    # The server on the m4-pro (hosts/m4-pro/atuin.nix)
    settings.sync_address = "https://atuin.miguelnascimento.dev";
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];
  };
}

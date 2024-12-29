_: {
  programs.starship = {
    enable = true;

    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = false;
      time = {
        format = "🕙 [$time]($style) ";
        disabled = true;
      };
    };
  };
}

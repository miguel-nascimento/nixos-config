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
      env_var.ZMX_SESSION = {
        symbol = " ";
        style = "bold yellow";
        format = "[$symbol$env_value]($style) ";
      };
    };
  };
}

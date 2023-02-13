{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
  ];

  # Colors like the Silver Searcher (ag)
  xdg.configFile."ripgrep/rc".text = ''
    --colors=line:fg:yellow
    --colors=line:style:bold
    --colors=path:fg:green
    --colors=path:style:bold
    --colors=match:fg:black
    --colors=match:bg:yellow
    --colors=match:style:nobold
  '';

  home.sessionVariables = {
    RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/rc";
  };
}

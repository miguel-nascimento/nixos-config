{ pkgs, ...}:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-nix ];
    extraConfig = ''
      set mouse=a
      set noexpandtab
      set tabstop=2
      set softtabstop=2
      set shiftwidth=2
    '';
  };
}
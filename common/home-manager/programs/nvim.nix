{ pkgs, ... }:
let 
  myVimConfigAsPlugin = pkgs.vimUtils.buildVimPlugin  {
    name = "user";
    src = ../../../config/nvim;
  };
in {
  imports = [ 
    ../languages/lua.nix
  ];
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped; # should I use the unwrapped one?
    plugins = [ myVimConfigAsPlugin ];
    extraLuaConfig = ''
      require('user')
    '';
    defaultEditor = true;
    withNodeJs = true; 
    withPython3 = true;
    withRuby = true;
  };
}
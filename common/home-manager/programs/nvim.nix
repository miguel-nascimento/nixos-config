{
  pkgs,
  ...
}:
let
  myVimConfigAsPlugin = pkgs.vimUtils.buildVimPlugin {
    name = "user";
    src = ../../../config/nvim;
    nvimSkipModules = [ "init" "user" "user.lazy" ];
  };
  # TODO: delete when https://github.com/NixOS/nixpkgs/issues/402998 is closed
  neovim-unwrapped = pkgs.unstable.neovim-unwrapped.overrideAttrs (old: {
    meta = old.meta or { } // {
      maintainers = [ ];
    };
  });
in
{
  imports = [ ../languages/lua.nix ];
  home.packages = with pkgs; [ gcc ]; # telescope requires this iirc
  programs.neovim = {
    enable = true;
    package = neovim-unwrapped;
    plugins = [ myVimConfigAsPlugin ];
    extraLuaConfig = ''
      require('user')
    '';
    defaultEditor = true;
    withRuby = true;
  };
}

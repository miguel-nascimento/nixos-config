# Note: Using buildVimPlugin to package the lua config is good for reproducibility
# and immutability, but it's just.. bleh terrible for iteration! Every config change
# requires a home-manager switch. Instead, we symlink the config directory directly.
#
# We also avoid programs.neovim since it creates a wrapper that rebuilds on every switch.
# Just install neovim as a plain package.
{
  pkgs,
  config,
  ...
}:
let
  nvimConfigPath = "${config.home.homeDirectory}/dev/nixos-config/config/nvim";
in
{
  imports = [ ../languages/lua.nix ];

  home.packages = with pkgs; [
    unstable.neovim
    gcc # telescope-fzf-native needs a C compiler
    gnumake # telescope-fzf-native build command is `make`
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  # Use config.lib.file.mkOutOfStoreSymlink to create a symlink to the actual
  # source directory, not a copy in the Nix store.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfigPath;
}

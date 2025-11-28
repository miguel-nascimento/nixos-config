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
{
  imports = [ ../languages/lua.nix ];

  home.packages = with pkgs; [
    unstable.neovim
    gcc # telescope requires this iirc
  ];

  home.sessionVariables.EDITOR = "nvim";

  # Use config.lib.file.mkOutOfStoreSymlink to create a symlink to the actual
  # source directory, not a copy in the Nix store.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/Users/miguel/dev/nixos-config/config/nvim";
}

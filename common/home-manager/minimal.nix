_: {
  imports = [
    ./programs/git.nix
    ./programs/lazygit.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/vim.nix
    ./programs/zsh.nix
    ./programs/nnn.nix
    ./programs/fzf.nix
    ./programs/bat.nix
    ./programs/ripgrep.nix
    ./programs/fd.nix
    ./programs/z.nix
    ./programs/jq.nix
    ./programs/eza.nix
    ./programs/nvim.nix

    ./languages/nix.nix
     # TODO: create a nvim.nix and move libc.nix to it
    ./languages/libc.nix # needed due to nvim
    ./languages/docs.nix
  ];
}

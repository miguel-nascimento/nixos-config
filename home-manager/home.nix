{ inputs, lib, config, pkgs, ... }: {
  # import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/vim.nix
    ./programs/zsh.nix
    ./programs/nnn.nix
    ./programs/fzf.nix
    ./programs/bat.nix
    ./programs/ripgrep.nix
    ./programs/fd.nix

    ./languages/nix.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "inugami";
    homeDirectory = "/home/inugami";
    packages = with pkgs; [ ];
  };

  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}

{
  inputs,
  pkgs,
  ...
}:
let
  qmd = inputs.qmd.packages.aarch64-darwin.default.overrideAttrs (old: {
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ (with pkgs; [
        xcbuild
        apple-sdk_15
      ]);

    # Upstream flake references src/qmd.ts but the entry point moved to src/cli/qmd.ts
    installPhase = builtins.replaceStrings [ "src/qmd.ts" ] [ "src/cli/qmd.ts" ] old.installPhase;
  });
in
{
  programs.home-manager.enable = true;
  imports = [
    ../common/home-manager/minimal.nix
    ../common/home-manager/programs/direnv.nix
    ../common/home-manager/programs/navi.nix
    ../common/home-manager/programs/fish.nix
    ../common/home-manager/programs/ai.nix
    ../common/home-manager/programs/herdr.nix
    ../common/home-manager/languages/docs.nix
    ../common/home-manager/languages/typescript.nix
    ../common/home-manager/languages/rust.nix
    ../common/home-manager/languages/go.nix
    ../common/home-manager/languages/java.nix
    ../common/home-manager/languages/zig.nix
    ../common/home-manager/programs/just.nix
    ../common/home-manager/programs/hyperfine.nix
    ../common/home-manager/programs/video.nix
    ../common/home-manager/programs/ghostty.nix
    ../common/home-manager/programs/apple-keychain.nix
  ];

  home = {
    username = "miguel";
    homeDirectory = "/Users/miguel";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.11";

    packages = [ qmd ];

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  programs.zsh.shellAliases.tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    useAppleKeychain = true;
    settings."*" = {
      IdentityFile = "~/.ssh/id_ed25519";
      Compression = false;
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
      ForwardAgent = false;
      HashKnownHosts = false;
      ServerAliveCountMax = 3;
      ServerAliveInterval = 0;
      UserKnownHostsFile = "~/.ssh/known_hosts";
    };
  };
}

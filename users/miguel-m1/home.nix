{ outputs, inputs, pkgs, ... }:
let
  zmx = pkgs.stdenv.mkDerivation {
    pname = "zmx";
    version = "0.4.0";
    src = pkgs.fetchurl {
      url = "https://zmx.sh/a/zmx-0.4.0-macos-aarch64.tar.gz";
      sha256 = "5b9bfd7358e904f1b5238421ddf5a87ab1445f483cb8e29e3d46519922c4bd8a";
    };
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      install -Dm755 zmx $out/bin/zmx
    '';
  };
  qmd = inputs.qmd.packages.aarch64-darwin.default.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ (with pkgs; [
      xcbuild
      apple-sdk_15
    ]);

    # Upstream flake references src/qmd.ts but the entry point moved to src/cli/qmd.ts
    installPhase = builtins.replaceStrings
      [ "src/qmd.ts" ]
      [ "src/cli/qmd.ts" ]
      old.installPhase;
  });
in
{
  programs.home-manager.enable = true;
  imports = [
    ../../common/home-manager/minimal.nix
    ../../common/home-manager/programs/direnv.nix
    ../../common/home-manager/programs/navi.nix
    ../../common/home-manager/programs/fish.nix
    ../../common/home-manager/programs/ai.nix
    ../../common/home-manager/languages/docs.nix
    ../../common/home-manager/languages/typescript.nix
    ../../common/home-manager/languages/rust.nix
    ../../common/home-manager/languages/go.nix
    ../../common/home-manager/languages/java.nix
    ../../common/home-manager/languages/zig.nix
    ../../common/home-manager/programs/just.nix
    ../../common/home-manager/programs/graphite.nix
    ../../common/home-manager/programs/hyperfine.nix
  ];

  # TODO: would be nice to share the same nixpkgs config as `mkHost.nix`
  nixpkgs = {
    # You can add overlays here
    overlays = [ outputs.overlays.unstable-packages ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "miguel";
    homeDirectory = "/Users/miguel";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.11";

    packages = [ qmd zmx ];

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  programs.zsh.shellAliases.tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

  # macOS SSH with Keychain integration
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      Host *
        UseKeychain yes
        IdentityFile ~/.ssh/id_ed25519
    '';
  };
}

{
  inputs,
  pkgs,
  system,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.wsl ];

  wsl = {
    enable = true;
    defaultUser = "miguel";
    startMenuLaunchers = true;
  };

  environment.systemPackages = [
    pkgs.lsof
    inputs.agenix.packages.${system}.agenix
  ];
  programs.zsh.enable = true;

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.11";
}

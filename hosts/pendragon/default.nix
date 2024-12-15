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
    useWindowsDriver = true;
    docker-desktop.enable = true;
  };

  environment.systemPackages = [
    pkgs.lsof
    inputs.agenix.packages.${system}.agenix
  ];
  programs.zsh.enable = true;
  virtualisation.docker.enable = true;
  # Enable nix flakes
  nix.package = pkgs.nixVersions.latest;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.11";
}

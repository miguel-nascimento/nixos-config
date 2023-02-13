{ pkgs, ... }:
{
  home.packages = with pkgs; [
    statix
    vulnix
    deadnix
    nil
    nixpkgs-fmt
  ];
}

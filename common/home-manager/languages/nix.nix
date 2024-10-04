{ pkgs, ... }:
{
  home.packages = with pkgs; [
    statix
    vulnix
    deadnix
    nixd
    nixfmt-rfc-style
  ];
}

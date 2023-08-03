
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    musl
    gcc
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [ unstable.eza ];
}

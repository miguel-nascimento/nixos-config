{ pkgs, ... }:
{
  home.packages = with pkgs; [ unstable.graphite-cli ];
}

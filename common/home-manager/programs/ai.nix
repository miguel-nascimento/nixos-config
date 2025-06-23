{ pkgs, ... }:
{
  home.packages = with pkgs; [ unstable.claude-code ];
}

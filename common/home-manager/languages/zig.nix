{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.zig
    unstable.zls
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.go
  ];
}

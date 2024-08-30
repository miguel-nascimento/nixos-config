{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    gopls
    cmake
  ];
}

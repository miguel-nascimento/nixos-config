
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    musl
    gcc
    man-pages
    man-pages-posix
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    python314
    uv
    unstable.ruff
  ];
}

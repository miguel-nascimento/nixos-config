{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    rustup
    libiconv
  ];

  home.sessionVariables = {
    LIBRARY_PATH = "${pkgs.libiconv}/lib";
  };
}

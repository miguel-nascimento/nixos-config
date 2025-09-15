{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    rustup
    libiconv
    zlib
    pkg-config
  ];

  home.sessionVariables = {
    LIBRARY_PATH = "${pkgs.libiconv}/lib:${pkgs.zlib}/lib";
    PKG_CONFIG_PATH = "${pkgs.libiconv}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig";
    # Add rustflags for rust-lld to find libraries
    RUSTFLAGS = "-L native=${pkgs.libiconv}/lib -L native=${pkgs.zlib}/lib -liconv -lz";
  };
}

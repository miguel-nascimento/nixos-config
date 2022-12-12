{ pkgs, ... }:
let
  hamaTvPlugin = pkgs.stdenv.mkDerivation {
    name = "Hama.bundle";
    src = pkgs.fetchFromGitHub {
      owner = "ZeroQI";
      repo = "Hama.bundle";
      rev = "16c8a40a7b004ed14e46cd457d8c393672a09c5a";
      sha256 = "08a0pfjr1ba9q41b0lcgmqrlj8i2a4d4irqxbckc5a1z6xzcr8nr";
    };
    buildInputs = [ pkgs.unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
  absoluteSeriesScanner = pkgs.fetchFromGitHub {
    owner = "ZeroQI";
    repo = "Absolute-Series-Scanner";
    rev = "773a39f502a1204b0b0255903cee4ed02c46fde0";
    sha256 = "4l+vpiDdC8L/EeJowUgYyB3JPNTZ1sauN8liFAcK+PY=";
  };
in
{
  services.plex = {
    enable = true;
    openFirewall = true;
    group = "users";
    extraPlugins = [ hamaTvPlugin ];
    extraScanners = [ absoluteSeriesScanner ];
  };
}

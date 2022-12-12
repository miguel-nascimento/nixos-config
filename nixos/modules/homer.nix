{ pkgs, ... }:
let 
  homerConfig = ./homer-config;
  homerPkg = pkgs.stdenv.mkDerivation {
    name = "homer";
    src = pkgs.fetchurl {
      url = "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip";
      sha256 = "sha256-rOaFjRSg85HDtYD/WJp4vnzBXdDOTazXtNHblMyqC6M=";
    };

    nativeBuildInputs = [ pkgs.unzip ];

    dontInstall = true;
    sourceRoot = ".";
    unpackCmd = "unzip -d $out $curSrc";

    fixupPhase = "cp -r ${homerConfig}/* $out/assets";
  };
in 
{
  networking.firewall.allowedTCPPorts = [ 8080 ];

  containers.homer = {
    autoStart = true;                
    extraFlags = [ "-U" ];

    config = { config, pkgs, ... }: {
      environment.systemPackages = [ homerPkg ];
      services.nginx = {                     
        enable = true; 
        virtualHosts."homer.local.cetacean.club" = {
          root = "${homerPkg}";
          listen = [ { port = 8080;  addr="0.0.0.0"; ssl=false; } ];
        };              
      };

      system.stateVersion = "22.11";

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 8080 ];
      };
    };
  };
}
{ pkgs, ... }:
let 
  # https://github.com/jellyfin/jellyfin-plugin-anidb
  anidbMetadata = pkgs.stdenv.mkDerivation {
    name = "jellyfin-plugin-anidb";
    src = pkgs.fetchurl {
      url = "https://repo.jellyfin.org/releases/plugin/anidb/anidb_7.0.0.0.zip";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    dontInstall = true;
    sourceRoot = ".";
    unpackCmd = "unzip -d $out $curSrc";
  };
  # https://github.com/vosmiic/jellyfin-ani-sync
  aniSyncPlugin = pkgs.stdenv.mkDerivation {
    name = "jellyfin-ani-sync";
    src = pkgs.fetchurl {
      url = "https://github.com/vosmiic/jellyfin-ani-sync/releases/download/v2.9/10.8.10.-.ani-sync_2.9.0.0.zip";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    dontInstall = true;
    sourceRoot = ".";
    unpackCmd = "unzip -d $out $curSrc";
  };
  jellyfinWithPlugins = {
    name = "custom-jellyfin";
    src = pkgs.jellyfin;
    buildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p $out;
      cp -R * $out/";
      mkdir -p $out/plugins/${anidbMetadata};
      mkdir -p $out/plugins/${aniSyncPlugin};
      cp -R ${anidbMetadata}/* $out/plugins/${anidbMetadata}/;
      cp -R ${aniSyncPlugin}/* $out/plugins/${aniSyncPlugin}/;
    '';
  };
in
{
  services.jellyfin = {
    package = jellyfinWithPlugins;
    enable = true;
    openFirewall = true;
  };
}

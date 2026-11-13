# m5: the daily laptop
{ pkgs, ... }:
let
  # Moonlight client from Nonary's fork (VRR, PyroWave, DualSense haptics),
  # to play on the Windows PC running Vibepollo. Only the nightlies ship a
  # macOS build; they're unsigned, which is fine from the store (no
  # quarantine flag). To update, bump the version and hash.
  moonlight = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "moonlight-nonary";
    version = "6.2.0-daily.199";
    src = pkgs.fetchurl {
      url = "https://github.com/Nonary/moonlight-qt/releases/download/v${version}/Moonlight-${version}.dmg";
      sha256 = "1317f8004375c286dcd952ceca6f3eb8084e211691f8e0f942ce18e172d48283";
    };
    # An APFS image, which undmg can't read
    nativeBuildInputs = [ pkgs._7zz ];
    unpackPhase = "7zz x -snld $src >/dev/null";
    installPhase = ''
      mkdir -p "$out/Applications"
      cp -R "$(find . -maxdepth 3 -name Moonlight.app | head -1)" "$out/Applications/"
    '';
  };
in
{
  environment.systemPackages = [ moonlight ];
}

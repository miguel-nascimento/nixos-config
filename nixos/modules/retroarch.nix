{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (retroarch.override {
      cores = [
        libretro.mupen64plus
        libretro.neocd
        libretro.snes9x
        libretro.swanstation
        libretro.beetle-gba
        libretro.dolphin
      ];
    })
    libretro.mupen64plus
    libretro.neocd
    libretro.snes9x
    libretro.swanstation
    libretro.beetle-gba
    libretro.dolphin
  ];
}

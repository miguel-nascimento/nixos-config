# NixOS config

## Hosts

- korone: NixOS Home Server
- pendragon: NixOS-WSL

## Users

- miguel: x86_64-linux user
- miguel-m1: aarch64-darwin user

## Home Manager usage

First, install Nix. I suggest using [nix-installer](https://github.com/DeterminateSystems/nix-installer) to install it.

After that, you can install home manager with `nix-shell -p home-manager` and then run `home-manager switch --flake .#user-from-users-list-here`

## Cool things

- [plex.nix](./common/system/plex.nix): Anime ready Plex Server with [Hama.bundle](https://github.com/ZeroQI/Hama.bundle) and [Absolute-Series-Scanner](https://github.com/ZeroQI/Absolute-Series-Scanner)

## Credits

Using [minimal nix-starter-config by Misterio77](https://github.com/Misterio77/nix-starter-configs) (thanks!!)

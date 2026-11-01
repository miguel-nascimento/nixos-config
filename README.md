# NixOS config

## Hosts

- korone: NixOS Home Server
- pendragon: NixOS-WSL
- m1-air, m4-pro, m5: macOS with nix-darwin

## Users

- miguel: x86_64-linux user
- miguel-mac: the Macs, applied by nix-darwin

## Home Manager usage

First, install Nix. I suggest using [nix-installer](https://github.com/DeterminateSystems/nix-installer) to install it.

After that, you can install home manager with `nix-shell -p home-manager` and then run `home-manager switch --flake .#user-from-users-list-here`

## New Mac

1. Install [Determinate Nix](https://determinate.systems/nix-installer/)
2. `nix run nixpkgs#git -- clone https://github.com/miguel-nascimento/nixos-config ~/dev/nixos-config`
3. `cd ~/dev/nixos-config && sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#m5`
4. SSH key from Bitwarden:
   ```sh
   nix shell nixpkgs#bitwarden-cli
   export BW_SESSION=$(bw login --raw)
   bw get item "SSH key" | jq -r .sshKey.privateKey > ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519
   bw get item "SSH key" | jq -r .sshKey.publicKey > ~/.ssh/id_ed25519.pub
   exit
   ```
5. `gh auth login --web && gh repo clone miguel-nascimento/notes ~/notes -- --branch obsidian`
6. `atuin login && atuin sync`
7. Sign in to Tailscale, Raycast and Obsidian
8. Install [Berkeley Mono](https://usgraphics.com/products/berkeley-mono)
9. System Settings → Displays → More Space

Afterwards: `sudo darwin-rebuild switch --flake .#m5`

## Cool things

- [plex.nix](./common/system/plex.nix): Anime ready Plex Server with [Hama.bundle](https://github.com/ZeroQI/Hama.bundle) and [Absolute-Series-Scanner](https://github.com/ZeroQI/Absolute-Series-Scanner)

## Credits

Using [minimal nix-starter-config by Misterio77](https://github.com/Misterio77/nix-starter-configs) (thanks!!)

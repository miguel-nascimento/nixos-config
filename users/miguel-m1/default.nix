{ config, pkgs, ... }:
{
  users.users.miguel = {
    isNormalUser = true;
    extraGroups = [ "users" "wheel" "docker" "networkmanager" ];
    # Since I'm not using nix-darwin, need to set the default using
    # $(which fish) >> /etc/shells
    # chsh -s $(which fish)
    # to change the default shell
    # Also, install fisher and nix-env.fish
    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6Bo70dehaX/OYMz094D35auxz5G0rdqf/tUj6ICn4a miguel-nascimento"
    ];
  };

  home-manager.users.miguel = import ./home.nix;
}

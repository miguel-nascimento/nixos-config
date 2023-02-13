{ config, pkgs, ... }:
{
  users.users.inugami = {
    isNormalUser = true;
    extraGroups = [ "users" "wheel" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6Bo70dehaX/OYMz094D35auxz5G0rdqf/tUj6ICn4a miguel-nascimento"
    ];
  };

  # Nicely reload system units when changing configs
  # systemd.user.startServices = "sd-switch";
  home-manager.users.inugami = import ./home.nix;
}

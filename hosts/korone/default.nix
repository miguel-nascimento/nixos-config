{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/system/deluge.nix
    ../../common/system/plex.nix
    ../../common/system/samba.nix
    ../../common/system/homer.nix
    ../../common/system/nix-config.nix
  ];

  networking.networkmanager = {
    enable = true;
    wifi.scanRandMacAddress = false;
  };
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  environment.variables.EDITOR = "vim";

  # Select internationalisation properties.
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "br-abnt2";
    useXkbConfig = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

  # Touchpad support
  services.xserver.libinput.enable = true;

  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  virtualisation.oci-containers.backend = "podman";
  environment.systemPackages = with pkgs; [
    cachix
    vim
    wget
    acpi
    rsync
    htop
    jdk17_headless
    unzip
    ngrok
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/system/deluge.nix
    ../../common/system/plex.nix
    ../../common/system/jellyfin.nix
    ../../common/system/samba.nix
    ../../common/system/homer.nix
    # ../../common/system/sonarr.nix
    ../../common/system/tailscale.nix
    ../../common/system/nextcloud.nix
  #  ../../common/system/nix-config.nix
  ];

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    # nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      # nix.package = pkgs.nixFlakes;
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  networking.networkmanager = {
    enable = true;
    wifi.scanRandMacAddress = false;
  };
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

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
    settings = { 
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
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

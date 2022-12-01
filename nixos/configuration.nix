{ inputs, lib, config, pkgs, ... }: {
  imports = [
    inputs.vscode-server.nixosModule

    ./hardware-configuration.nix
    ./modules/deluge.nix
    ./modules/plex.nix
    # ./modules/retroarch.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  networking.hostName = "korone";

  powerManagement = {
    powertop.enable = true;
    scsiLinkPolicy = "med_power_with_dipm";
  };

  networking.networkmanager.enable = true; 
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  environment.variables.EDITOR = "vim";

  services.logind.lidSwitch = "ignore";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "br-abnt2";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

  # Touchpad support
  services.xserver.libinput.enable = true;

  users.users.inugami = {
    isNormalUser = true;
    extraGroups = [ "users" "wheel" "docker" ]; 
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # TODO: Add SSH public key here
    ];
  };

  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    permitRootLogin = "no";
    # TODO: switch to use keys only.
    passwordAuthentication = true;
  };

  # Vscode SSH Server
  services.vscode-server.enable = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
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

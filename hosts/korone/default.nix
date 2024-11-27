{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/deluge.nix
    ../../common/system/plex.nix
    ../../common/system/jellyfin.nix
    ../../common/system/samba.nix
    ../../common/system/homer.nix
    ../../common/system/tailscale.nix
  ];

  networking = {
    networkmanager = {
      enable = true;
      wifi.scanRandMacAddress = false;
      insertNameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
    firewall.enable = true;
    firewall.allowPing = true;
  };

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
  environment.systemPackages =
    with pkgs;
    [
      acpi
      jdk22_headless
      ngrok
    ]
    ++ [ inputs.agenix.packages.${system}.agenix ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}

_:
{
  networking.firewall.allowedTCPPorts = [ 8112 ];
  networking.firewall.allowedUDPPorts = [ 8112 ];

  services.deluge = {
    enable = true;
    declarative = true;
    openFirewall = true;
    authFile = "/var/deluge-auth-file";
    config = {
      download_location = "/media/home-server/downloads";
      ignore_resume_timestamps = true;
    };
    web = {
      enable = true;
      openFirewall = true;
    };
  };
}

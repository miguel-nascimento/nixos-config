_:
{
  services.samba-wsdd= {
    # make shares visible for windows 10 clients
    enable = true;
    openFirewall = true;
  };
  # networking.firewall.allowedTCPPorts = [ 5357 ];
  # networking.firewall.allowedUDPPorts = [ 3702 ];

  services.samba = {
    openFirewall = true;
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';

    shares = {
      public = {
        path = "/media/home-server";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "inugami";
        "force group" = "users";
      };
    };
  };
}

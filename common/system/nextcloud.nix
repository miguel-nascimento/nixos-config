{ pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "korone";
    config.adminpassFile = "${pkgs.writeText "user" "pass"}";
    configureRedis = true;
  };
}

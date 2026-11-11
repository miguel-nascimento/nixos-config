let
  miguel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6Bo70dehaX/OYMz094D35auxz5G0rdqf/tUj6ICn4a";
  m4-pro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINVinCTlkCinF+KKp+5DOROqAPKF1iaEm2FMgHZQ6P+/";
in
{
  "tailscale.age".publicKeys = [ miguel ];
  "cloudflare-dns.age".publicKeys = [
    miguel
    m4-pro
  ];
  "couchdb-admin.age".publicKeys = [
    miguel
    m4-pro
  ];
}

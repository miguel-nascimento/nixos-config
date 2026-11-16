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
  "camera-quarto.age".publicKeys = [
    miguel
    m4-pro
  ];
  "couchdb-admin.age".publicKeys = [
    miguel
    m4-pro
  ];
  # Emissor de NFS-e (hosts/m4-pro/emissor-nfse.nix). The .pfx is binary, so encrypt the file itself:
  #   age -r "<miguel>" -r "<m4-pro>" -o nfse-certificate.age certificado.pfx
  # and the password with `agenix -e nfse-certificate-password.age`.
  "nfse-certificate.age".publicKeys = [
    miguel
    m4-pro
  ];
  "nfse-certificate-password.age".publicKeys = [
    miguel
    m4-pro
  ];
}

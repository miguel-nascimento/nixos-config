let 
  miguel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6Bo70dehaX/OYMz094D35auxz5G0rdqf/tUj6ICn4a";
in 
{
  "tailscale.age".publicKeys = [miguel];
}

_:
{
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    agents = ["ssh"];
    keys = [ "id_ed25519" ];
  };
}

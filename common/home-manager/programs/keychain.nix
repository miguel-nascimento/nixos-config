_:
{
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    agents = ["ssh"];
    keys = [ "id_ed25519" ];
  };
}

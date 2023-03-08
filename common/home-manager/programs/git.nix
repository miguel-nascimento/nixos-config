_:
{
  programs.git = {
    enable = true;

    aliases = {
      cm = "commit -m";
    };

    difftastic.enable = true;
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };

    userEmail = "miguelgomes13@live.com";
    userName = "Miguel Nascimento";
  };
}

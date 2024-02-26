_:
{
  programs.git = {
    enable = true;

    aliases = {
      cm = "commit -m";
      lg = "log --format='%Cred%h%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset%C(yellow)%d%Creset' --no-merges";
    };

    delta.enable = true;
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };

    userEmail = "miguelgomes13@live.com";
    userName = "Miguel Nascimento";
  };
}

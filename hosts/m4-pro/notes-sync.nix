# Every hour, if ~/notes changed, commit it and sync with GitHub.
# This Mac is the only git writer; the other clients sync through LiveSync.
{ pkgs, user, ... }:
let
  notes = "/Users/${user}/notes";
  sync = pkgs.writeShellApplication {
    name = "notes-sync";
    runtimeInputs = with pkgs; [
      git
      git-lfs
      gh
      openssh
      coreutils
    ];
    text = ''
      cd ${notes}
      git add -A
      if ! git diff --cached --quiet; then
        git commit --quiet -m "vault backup: $(date '+%Y-%m-%d %H:%M:%S')"
      fi
      if ! git pull --quiet --rebase --autostash; then
        git rebase --abort || true
        echo "notes-sync: pull failed, left for a human" >&2
        exit 1
      fi
      if [ -n "$(git log '@{u}..' --oneline)" ]; then
        git push --quiet
      fi
    '';
  };
in
{
  environment.systemPackages = [ sync ];

  launchd.user.agents.notes-sync.serviceConfig = {
    ProgramArguments = [ "${sync}/bin/notes-sync" ];
    StartInterval = 3600;
    RunAtLoad = true;
    StandardOutPath = "/Users/${user}/Library/Logs/notes-sync.log";
    StandardErrorPath = "/Users/${user}/Library/Logs/notes-sync.log";
  };
}

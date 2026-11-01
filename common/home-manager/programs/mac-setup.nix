{ config, pkgs, ... }:
let
  # The steps nix can't do for a new Mac: they need a password or a browser.
  # Safe to run again; finished steps are skipped.
  mac-setup = pkgs.writeShellApplication {
    name = "mac-setup";
    runtimeInputs = [
      config.programs.atuin.package
      pkgs.bitwarden-cli
      config.programs.gh.package
      pkgs.git
      pkgs.jq
    ];
    text = ''
      if [ -f ~/.ssh/id_ed25519 ]; then
        echo "ssh: ~/.ssh/id_ed25519 already there"
      else
        echo "ssh: fetching the key from Bitwarden"
        if bw login --check >/dev/null 2>&1; then
          session=$(bw unlock --raw)
        else
          session=$(bw login --raw)
        fi
        bw sync --session "$session" >/dev/null
        keys=$(bw list items --session "$session" | jq '[.[] | select(.type == 5)]')
        count=$(jq length <<<"$keys")
        if [ "$count" -eq 0 ]; then
          echo "ssh: no SSH key item in Bitwarden. Add one, then run mac-setup again"
          exit 1
        fi
        pick=0
        if [ "$count" -gt 1 ]; then
          jq -r 'to_entries[] | "\(.key + 1)) \(.value.name)"' <<<"$keys"
          read -rp "Which key? " choice
          pick=$((choice - 1))
        fi
        mkdir -p ~/.ssh && chmod 700 ~/.ssh
        (umask 077; jq -r ".[$pick].sshKey.privateKey" <<<"$keys" > ~/.ssh/id_ed25519)
        jq -r ".[$pick].sshKey.publicKey" <<<"$keys" > ~/.ssh/id_ed25519.pub
        bw lock >/dev/null
        echo "ssh: wrote ~/.ssh/id_ed25519 ($(jq -r ".[$pick].name" <<<"$keys"))"
      fi

      if gh auth status >/dev/null 2>&1; then
        echo "github: already logged in"
      else
        echo "github: log in (opens a browser)"
        # git already uses gh for github.com: programs.gh.gitCredentialHelper in git.nix
        gh auth login --web --git-protocol https
      fi

      if [ -d ~/notes/.git ]; then
        echo "notes: already cloned"
      else
        echo "notes: cloning into ~/notes"
        gh repo clone miguel-nascimento/notes ~/notes -- --branch obsidian
      fi

      if atuin status >/dev/null 2>&1; then
        echo "atuin: already syncing"
      else
        echo "atuin: log in (an account made on another Mac needs that Mac's 'atuin key')"
        read -rp "Do you have an atuin account? [y/N] " has_account
        if [[ "$has_account" == [yY]* ]]; then atuin login; else atuin register; fi
        atuin sync
      fi

      if /Applications/Tailscale.app/Contents/MacOS/Tailscale status >/dev/null 2>&1; then
        echo "tailscale: already connected"
      else
        echo "tailscale: sign in from the menu bar"
        open -a Tailscale
      fi

      echo "opening Raycast and Obsidian for their first-run setup (Raycast already has ⌘Space)"
      open -a Raycast
      open -a Obsidian
    '';
  };
in
{
  home.packages = [ mac-setup ];
}

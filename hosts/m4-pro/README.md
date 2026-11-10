# m4-pro: the home server

A MacBook Pro with the lid closed, reached over Tailscale. It runs:

- **CouchDB** for Obsidian's [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync).
  It's the `couchdb3` package from nixpkgs running as a launchd daemon (no Docker),
  listening on localhost. `tailscale serve` puts it at
  `https://miguel-m4.boreray-eel.ts.net:6984`, for the tailnet only.
- **notes-sync**, which runs every hour: if `~/notes` changed, it commits, pulls with rebase and pushes.
  The log is at `~/Library/Logs/notes-sync.log`. Run it now with `notes-sync`.
- **Home Assistant** ([home-assistant.nix](./home-assistant.nix)), the nixpkgs
  package as a launchd agent started at login, data in `~/.homeassistant`.
  `tailscale serve` puts it at `https://miguel-m4.boreray-eel.ts.net:8123`.
- **Zigbee2MQTT** + **Mosquitto** ([zigbee2mqtt.nix](./zigbee2mqtt.nix)): the Zigbee
  network on the SMLIGHT SLZB-06Mu stick (USB, `/dev/cu.usbmodem2101`, EmberZNet 8.0.2,
  `adapter: ember`), published to Home Assistant over MQTT on localhost.
  Its UI is at `https://miguel-m4.boreray-eel.ts.net:8124`; its data (including the
  network key) is in `~/.zigbee2mqtt`, backed up in `~/Backups`.
- **Obsidian**, opened at login. Its LiveSync writes what the other devices
  sync into `~/notes`, and notes-sync puts that into git.

The m4 is the only device that uses git for notes. Every other device syncs
through LiveSync.

## Apply

```sh
cd ~/dev/nixos-config && sudo darwin-rebuild switch --flake .#m4-pro
```

CouchDB login: user `miguel`. Read the password with
`sudo cat /run/agenix/couchdb-admin` on the m4, or `agenix -d couchdb-admin.age`
in `secrets/`. Change it with `agenix -e couchdb-admin.age`, then switch.

Check it's up:

```sh
curl -u miguel:<password> https://miguel-m4.boreray-eel.ts.net:6984/_all_dbs   # ["_replicator","_users"]
```

## LiveSync setup

The plugin is already in the vault (`.obsidian/plugins/obsidian-livesync`), so
a `git pull` of `~/notes` brings it to every Mac. Its settings, including the
CouchDB login, stay out of git.

### 1. The m4 first: it uploads the vault

1. Pull `~/notes` so it's current, then open it in Obsidian.
2. Settings → Community plugins → turn on **Self-hosted LiveSync**.
3. Its setup wizard → set it up from scratch, **manual setup**:
   - Remote: CouchDB
   - URI: `https://miguel-m4.boreray-eel.ts.net:6984`
   - Username `miguel`, password from above
   - Database name: `notes`
   - Click the button that checks the connection, then the one that checks
     the database configuration. Everything should come back green, since the
     server already has LiveSync's settings.
4. Pick an **end-to-end encryption passphrase** and save it in Bitwarden. Every
   device needs it.
5. Sync mode: **LiveSync**.
6. Under Selective sync / ignore patterns, add the files LiveSync shouldn't carry:
   - `\.blend$`, `\.exr$`: big binaries; they stay in git (LFS)
   - `^memory/`: every Mac's Claude writes its own copy; syncing them live
     would make conflicts. They still reach git from the m4.
7. Let it upload the vault. That's the first sync, or "rebuild everything" /
   send local to remote.
8. Run the command **Copy settings as a new setup URI**, protected by a
   passphrase. Every other device sets up from this URI.

### 2. Every other Mac

1. `cd ~/notes && git pull`, so its files match what the m4 uploaded.
2. In Obsidian, turn off **obsidian-git** and turn on **Self-hosted LiveSync**.
3. Run the command **Use the copied setup URI**, paste it, enter its
   passphrase, and set up as an extra device that **fetches from the remote**.
4. From then on, don't `git pull` or commit in that `~/notes`.

### 3. iPhone / iPad

1. Install Tailscale and sign in.
2. Create a new empty vault `notes` in Obsidian.
3. Install Self-hosted LiveSync from Community plugins.
4. Use the setup URI as in step 2.3.

## Home Assistant

Nix owns `configuration.yaml` (a symlink into the store). The rest is made in
the UI and kept in `~/.homeassistant`: dashboards, integrations, devices,
automations, scenes and scripts.

A new integration needs its Python packages in the build. Add it to
`extraComponents` in `home-assistant.nix` and switch, then set it up in the UI.

Logs are at `~/Library/Logs/home-assistant.log`. Restart with
`launchctl kickstart -k gui/$(id -u)/org.nixos.home-assistant`.

## Troubleshooting

- `sudo launchctl kickstart -k system/org.nixos.couchdb` restarts CouchDB. Its log is at `/var/log/couchdb.log`.
- `tailscale serve status` should list `:6984 → http://127.0.0.1:5984`.
- If notes-sync can't pull with rebase, it stops and leaves the repo alone. Fix
  `~/notes` by hand and it picks up again next hour.

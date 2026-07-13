# smart-plug-charge-limiter

Keeps a laptop battery cycling between `LOW%` and `HIGH%` by switching a
TP-Link Tapo smart plug (the charger) on and off:

- at/above **79%** → plug **off** (stop charging)
- at/below **60%** → plug **on** (resume charging)

Between the two it leaves the plug alone (hysteresis), so it doesn't flap.
Edit `HIGH`/`LOW` at the top of the script to change the band.

## Prerequisites

The [`kasa`](https://python-kasa.readthedocs.io) CLI, installed isolated via pipx:

```bash
pipx install python-kasa
```

Your Tapo device must have **Third-Party Compatibility** enabled
(Tapo app → *Me* → *Third-Party Services*) — firmware 1.4.x disables it by
default, which makes the plug unreachable locally.

## Configuration

The plug is located by its **alias** (its name in the Tapo app) via UDP
discovery, so it works even when your router hands it a different IP each time —
no reserved/static IP required.

The script reads these variables from the environment (the `kasa` CLI picks
credentials up natively, so none live in the repo):

| Variable        | Meaning                                              |
|-----------------|------------------------------------------------------|
| `KASA_ALIAS`    | Plug's name in the Tapo app (used to discover it)    |
| `KASA_USERNAME` | TP-Link account email                                |
| `KASA_PASSWORD` | TP-Link account password                             |
| `KASA_BIN`      | Path to `kasa` (default: `kasa`)                     |

## Run manually

```bash
export KASA_ALIAS="Tapo P110"
export KASA_USERNAME=you@example.com
export KASA_PASSWORD=...
./smart-plug-charge-limiter.sh
```

## Run as a systemd user service

1. Copy the env file and lock it down:

   ```bash
   mkdir -p ~/.config/smart-plug
   cp env.example ~/.config/smart-plug/env
   chmod 600 ~/.config/smart-plug/env
   $EDITOR ~/.config/smart-plug/env      # fill in real values
   ```

2. Install and start the unit:

   ```bash
   mkdir -p ~/.config/systemd/user
   cp smart-plug-charge-limiter.service ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now smart-plug-charge-limiter.service
   ```

   > The unit assumes the repo lives at `~/github-projects/bash-scripts`.
   > Adjust `ExecStart` if yours is elsewhere.

3. Check status / logs:

   ```bash
   systemctl --user status smart-plug-charge-limiter.service
   journalctl --user -u smart-plug-charge-limiter.service -f
   ```

To keep the service running while logged out:

```bash
sudo loginctl enable-linger "$USER"
```

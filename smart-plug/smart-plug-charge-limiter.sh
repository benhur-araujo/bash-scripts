#!/usr/bin/env bash
#
# Keeps the laptop battery cycling between LOW% and HIGH% by switching a
# TP-Link Tapo smart plug (the charger) on and off.
#
#   - At/above HIGH% -> plug OFF (stop charging)
#   - At/below  LOW% -> plug ON  (resume charging)
#
# The `kasa` CLI reads these from the environment; export them before running
# (e.g. from ~/.profile or a systemd unit) so no credentials live in this repo:
#
#   export KASA_HOST=192.168.0.91
#   export KASA_USERNAME=you@example.com
#   export KASA_PASSWORD=your-tplink-password

set -u

HIGH=79            # turn the plug OFF at or above this capacity
LOW=60             # turn the plug ON at or below this capacity
BATTERY="BAT0"
INTERVAL=15

# Path to the `kasa` CLI (python-kasa). Override KASA_BIN with an absolute path
# when PATH is minimal (e.g. a systemd unit): KASA_BIN=$HOME/.local/bin/kasa
KASA_BIN="${KASA_BIN:-kasa}"

: "${KASA_HOST:?Set KASA_HOST to the smart plug IP}"
: "${KASA_USERNAME:?Set KASA_USERNAME to your TP-Link account email}"
: "${KASA_PASSWORD:?Set KASA_PASSWORD to your TP-Link account password}"

command -v "$KASA_BIN" >/dev/null 2>&1 || {
    echo "kasa CLI not found: '$KASA_BIN'. Install with 'pipx install python-kasa'," \
         "or set KASA_BIN to its absolute path." >&2
    exit 1
}

plug_state="unknown"   # unknown | on | off

# Switch the plug; on success update plug_state.
set_plug() {
    local action="$1"
    if "$KASA_BIN" --host "$KASA_HOST" "$action" >/dev/null 2>&1; then
        plug_state="$action"
    fi
}

while sleep "$INTERVAL"; do
    capacity=$(<"/sys/class/power_supply/$BATTERY/capacity")

    if (( capacity >= HIGH )); then
        [[ "$plug_state" != "off" ]] && set_plug off
    elif (( capacity <= LOW )); then
        [[ "$plug_state" != "on" ]] && set_plug on
    fi
done

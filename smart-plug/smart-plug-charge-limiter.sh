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
#   export KASA_ALIAS="Tapo P110"          # the plug's name in the Tapo app
#   export KASA_USERNAME=you@example.com
#   export KASA_PASSWORD=your-tplink-password
#
# The plug is located by its alias via UDP discovery on every switch, so a
# fixed/reserved IP is NOT required.

set -u

HIGH=79            # turn the plug OFF at or above this capacity
LOW=60             # turn the plug ON at or below this capacity
BATTERY="BAT0"
INTERVAL=15

# Path to the `kasa` CLI (python-kasa). Override KASA_BIN with an absolute path
# when PATH is minimal (e.g. a systemd unit): KASA_BIN=$HOME/.local/bin/kasa
KASA_BIN="${KASA_BIN:-kasa}"

: "${KASA_USERNAME:?Set KASA_USERNAME to your TP-Link account email}"
: "${KASA_PASSWORD:?Set KASA_PASSWORD to your TP-Link account password}"

# Locate the plug by alias, discovered each time, so a dynamic IP is fine.
: "${KASA_ALIAS:?Set KASA_ALIAS to the plug alias (its name in the Tapo app)}"
TARGET=(--alias "$KASA_ALIAS")

command -v "$KASA_BIN" >/dev/null 2>&1 || {
    echo "kasa CLI not found: '$KASA_BIN'. Install with 'pipx install python-kasa'," \
         "or set KASA_BIN to its absolute path." >&2
    exit 1
}

plug_state="unknown"   # unknown | on | off

# Switch the plug; on success update plug_state. When targeting by alias the
# `kasa` CLI rediscovers the current IP, so this self-heals across IP changes.
set_plug() {
    local action="$1"
    if "$KASA_BIN" "${TARGET[@]}" "$action" >/dev/null 2>&1; then
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

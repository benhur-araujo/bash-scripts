#!/usr/bin/env bash

THRESHOLD=85
BATTERY="BAT0"
NOTIFIED=0

while sleep 15; do
    capacity=$(<"/sys/class/power_supply/$BATTERY/capacity")
    status=$(<"/sys/class/power_supply/$BATTERY/status")

    if [[ "$status" == "Charging" ]]; then
        if (( capacity >= THRESHOLD && NOTIFIED == 0 )); then
            notify-send \
                -u critical \
                -t 0 \
                "Battery ${capacity}%" \
                "Time to unplug the charger."

            NOTIFIED=1
        fi
    else
        NOTIFIED=0
    fi
done

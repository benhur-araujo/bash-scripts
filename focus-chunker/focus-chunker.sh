#!/bin/bash

# Manage gnome-notifications
gnome_notifications(){
    local action="$1"
    gsettings set org.gnome.desktop.notifications show-banners "$action"
}

short_break(){
    gnome_notifications "true"
    for (( i=1; i <= 300; i++ )); do
        clear
        echo "Short resting for $((i / 60)) minutes"
        sleep 1
    done

    notify-send "Short break is over!"
    read -p "Get back to work! Press f to return to focus: " decision
    case ${decision,,} in
        f) continue;;
        *) exit 1;;
    esac    
}

long_break(){
    gnome_notifications "true"
    for (( i=1; i <= 1200; i++ )); do
        clear
        echo "Long resting for $((i / 60)) minutes"
        sleep 1
    done
    
    notify-send "Well done! You completed a full cycle"
    exit 0
}

pomodoro() {
    ran_times=0
    converted_to_seconds=$(($1 * 60 ))

    while true; do
        gnome_notifications "false"
        for ((i = 1; i <= $converted_to_seconds; i++ )); do
            clear
            echo "Focusing for $((i / 60)) minutes"
            sleep 1
        done
        ran_times=$((ran_times + 1))

        if [[ $ran_times -lt 3 ]]; then
            notify-send "Focus time ended! Go to a short break!"
            short_break
        else
            long_break
        fi    
    done
}

main() {
    minutes=$1
    pomodoro ${minutes:-25} 
}

main "$@"

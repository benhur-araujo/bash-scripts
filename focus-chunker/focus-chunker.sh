#!/bin/bash

# Manage gnome-notifications
gnome_notifications(){
    local action="$1"
    gsettings set org.gnome.desktop.notifications show-banners "$action"
}
    
trap 'gnome_notifications "true"; exit 1' INT

short_break(){
    for (( i=1; i <= "$min_to_short_rest"; i++ )); do
        clear
        min_resting=$(( i / 60 ))
        if [[ $min_resting -eq 0 ]]; then
            echo "Short resting for $i seconds"
        else
            echo "Short resting for $min_resting minutes"
        fi
        sleep 1
    done
    
    notify-send "Short break is over!"
    echo -n $'\a'
    read -p "Get back to work! Press f to return to focus: " decision
    case ${decision,,} in
        f) continue;;
        *) exit 1;;
    esac    
}

long_break(){
    for (( i=1; i <= "$min_to_long_rest"; i++ )); do
        clear
        min_resting=$(( i / 60 ))
        if [[ $min_resting -eq 0 ]]; then
            echo "Long resting for $i seconds"
        else
            echo "Long resting for $min_resting minutes"
        fi
        sleep 1
    done
}

pomodoro() {
    ran_times=0
    min_to_seconds=$(($1 * 60 ))

    while true; do
        gnome_notifications "false"
        for ((i = 1; i <= $min_to_seconds; i++ )); do
            clear
            min_focusing=$((i / 60))
            if [[ $min_focusing -eq 0 ]]; then
                echo "Focusing for $i seconds"
            else
                echo "Focusing for $min_focusing" minutes
            fi
            sleep 1
        done
        
        ran_times=$((ran_times + 1))
        gnome_notifications "true"
        
        if [[ $ran_times -lt 3 ]]; then
            notify-send "Focus time ended! Go to a short break!"
            echo -n $'\a'
            short_break
        else
            notify-send "Well done! You completed a full cycle!"
            echo -n $'\a'
            long_break

            
            read -p "Do you want to begin a new cycle? y/n: " decision
            if [[ "$decision" == "y" ]]; then
                pomodoro $1
            else
                exit 0
            fi
        fi    
    done
}

main() {
    min_to_focus=${1:-25}
    min_to_short_rest=300
    min_to_long_rest=1200

    pomodoro $min_to_focus
}

main "$@"


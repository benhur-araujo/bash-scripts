#!/bin/bash

set -e -o nounset

usage() {
    cat <<EOF
Usage: ./$0 [OPTION]...

Options:
  -d DIR    specify the directory to be analyzed.
  -r LEVEL  set recursively level. Default: 0
  -s        show disk summary.
  -c        clean unnecessary logs, files & apt packages.

Examples:
  ./$0                  # Show disk summary
  ./$0 -d /tmp          # Will analyze /tmp
  ./$0 -r 1 -d /tmp     # Will analyze /tmp and /tmp/*

EOF
    exit 1
}

# Default recursivity level
max_depth=0

disk_summary() {
    echo "### Disks Summary  ###"
    df -h
    
    echo -e "\n### Root level consumption ###"
    du -hs -t 1m /* 2> /dev/null | sort -h

    local unused_packages="$(sudo apt-get autoremove -s | grep "disk space will be freed")"
    if [[ "$unused_packages" ]]; then
        echo -e "\n # Unused apt packages and old kernels #"
        echo "$unused_packages"
    fi

    echo -e "\n# Disk space used by apt cache"
    sudo du -sh /var/cache/apt | awk '{print $1}'

    echo -e "\n# Disk space used by logs"
    journalctl --disk-usage | grep -oE '[0-9]+(\.[0-9]+)?[KMG]'

    echo -e "\n# Disk space used by old snap revisions"
    snaps_dir="/var/lib/snapd/snaps/"
    snaps_size=0

    while read snap revision; do
        size=$(du "$snaps_dir"/"$snap"_"$revision".snap | awk '{print $1}')
        snaps_size=$(( $snaps_size + $size ))
    done < <(snap list --all | awk '/disabled/{print $1, $3}')

    readable_snaps_size=$(numfmt --from-unit=1K --to=iec $snaps_size)
    echo -e "$readable_snaps_size\n"
}

dir_size() {
    local depth="$1"
    local dir="$2"
    echo -e "\n### Directory disk usage ###"
    du -hd "$depth" "$dir" | sort -h
}

clean_up() {
    echo -e "\n# Removing unused apt packages and old kernels..."
    sudo apt autoremove > /dev/null 2>&1
    sudo apt clean > /dev/null 2>&1
    echo "Done!"
    
    echo -e "\n# Deleting system logs older than 3d..."
    sudo journalctl --vacuum-time=3d > /dev/null 2>&1
    echo "Done!"

    echo -e "\n# Deleting old revisions of snaps..."
    snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision" > /dev/null 2>&1
    done
    echo "Done!"
}

# Processing options
get_opts() {
    clean="false"
    while getopts "r:d:cs" opt; do
        case "$opt" in
            c) clean="true";;
            s) show_summary="true";;
            r) max_depth="$OPTARG";;
            d) dir="$OPTARG";;
            *) usage;;
         esac
     done
}


main () {
    get_opts "$@"
    
    if [[ "${show_summary:-false}" == "true" ]]; then
        disk_summary
    elif [[ "$clean" == "true" ]]; then
        clean_up
    elif [[ -n "${dir:-}" ]]; then
        if [[ -d "$dir" ]]; then
            dir_size "$max_depth" "$dir"
        else
            echo "Error: Directory $dir does not exist."
            exit 1
        fi
    else
        disk_summary
        while true; do
            read -p "Do you want to clean the disk? y/n: " clean
            case "${clean,,}" in
                y) clean_up && exit 0;;
                n) exit 0;;
                *) echo "Invalid, press 'y' or 'n'.";;
            esac
        done
    fi
}

main "$@"

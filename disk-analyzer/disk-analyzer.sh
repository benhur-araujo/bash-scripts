#!/bin/bash

set -e -o nounset

usage() {
    cat <<EOF
Usage: ./$0 [OPTION]...

Options:
  -d  specify the directory to be analyzed. Default: /home
  -r  set recursively level. Default: 0

Examples:
  ./disk-analyzer              # Will analyze /home
  ./disk-analyzer -d /tmp      # Will analyze /tmp
  ./disk-analyzer -r 1 -d /tmp # Will analyze /tmp and /tmp/*

EOF
    exit 1
}

# Default directory & recursivity level
dir="/home"
max_depth=0

disk_summary() {
    echo "### Disks Summary  ###"
    df -h
    echo -e "\n### Root level consumption ###"
    du -hs -t 1m /* 2> /dev/null | sort -h
}

dir_size() {
    echo -e "\n### Directory disk usage ###"
    du -hd "$1" "$2" | sort -h
}

# Processing options
while getopts "r:d:s" opt; do
    case "$opt" in
        s) disk_summary;;
        r) max_depth="$OPTARG";;
        d) dir="$OPTARG";;
        \?) usage;;
     esac
 done


main () {
    if [[ "$#" -eq 0 ]]; then
        disk_summary
        exit 1
    fi
    
    dir_size $max_depth "$dir"
}

main "$@"

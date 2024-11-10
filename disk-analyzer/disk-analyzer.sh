#!/bin/bash

set -e -o nounset -o pipefail

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

# Processing options
if [[ "$#" -eq 0 ]]; then
    dir="/home"
else
    while getopts "r:d:" opt; do
        case "$opt" in
            r) max_depth="$OPTARG";;
            d) dir="$OPTARG";;
            \?) usage;;
         esac
     done
fi

dir_size() {
    du -h -d "$1" "$2"
}

main () {
    dir_size "${max_depth:-0}" "$dir"
}

main

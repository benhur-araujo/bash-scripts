#!/bin/bash

set -e -o nounset -o pipefail

usage() {
    cat <<EOF
Usage: ./$0 [OPTION]...

Options:
  -d  specify the directory to be analyzed. Default: /home

Examples:
  ./disk-analyzer             # Will analyze /home
  ./disk-analyzer -d /tmp     # Will analyze /tmp        

EOF
    exit 1
}

# Processing options
if [[ "$#" -eq 0 ]]; then
    dir="/home"
elif [[ "$#" -eq 2 ]]; then
    getopts "d:" opt
        case "$opt" in
            d) dir="$OPTARG";;
            \?) usage;;
         esac
else
    usage
fi

dir_size() {
    du -hs "$1"
}

main () {
    dir_size "$dir"
}

main

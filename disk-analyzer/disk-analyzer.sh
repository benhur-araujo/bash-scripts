#!/bin/bash

set -e -o nounset -o pipefail

dir="${1:-/home}"

usage() {
    echo -e "Usage: $0 [OPTION]... \n"
    echo "Options:"
    echo -e "  -d  specify the directory to be analyzed. Default: /home \n"
    echo "Examples:"
    echo "  ./disk-analyzer             # Will analyze /home"
    echo "  ./disk-analyazer -d /tmp    # Will analyze /tmp"
}

dir_size() {
    du -hs "$dir"
}


main () {
    dir_size
}

main

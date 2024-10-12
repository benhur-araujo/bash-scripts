#!/bin/bash
set -eo pipefail

usage() {
    echo "Usage: $0 [-s] # Shutdown system after updating it."
    exit 1
}

update_apt_indexes() {
    sudo apt update -y && return 0 || return 1
}

update_apt_packages() {
    sudo apt upgrade -y && return 0 || return 1
}

shutdown_system() {
    shutdown -h now
}

main() {
    if [[ "$#" -eq 0 ]]; then
        update_apt_indexes
        update_apt_packages
    elif [[ "$#" -eq 1 && "$1" == "-s" ]]; then
        update_apt_indexes
        update_apt_packages
        shutdown_system
    else
        usage
    fi
}

main "$@"

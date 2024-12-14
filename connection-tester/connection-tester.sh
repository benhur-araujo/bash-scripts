#!/bin/bash
# 
usage() {
    echo "Usage: $0 [remote_address]"
    echo
    echo "This script tests the Local Area Network (LAN) and Internet connection."
    echo
    echo "Arguments:"
    echo "  remote_address  # The remote address to ping for testing the Internet connection (default: 1.1.1.1)."
    echo
    echo "Example:"
    echo "  $0 8.8.8.8"
    exit 1
}

# Show how to use this script
if [[ "$#" -gt 1 ]]; then
    usage
fi

# Get local gateway address
gw_ip="$(ip route | head -n1 | awk '{print $3}')"

# Remote address to reach to
remote_address="${1:-1.1.1.1}"

# Test Local Area Network(LAN) connection
test_lan() {
    local ping_output="$(ping -c 5 $gw_ip)"
    local packet_loss="$(echo $ping_output | sed -E 's/.* ([0-9]+)% packet loss.*/\1/')"
    local avg_latency="$(echo $ping_output | cut -d"/" -f5)"

    if [[ "$packet_loss" -eq 100 ]]; then
        echo "Unable to reach Local Gateway"
        exit 1
    elif [[ "$packet_loss" -gt 20 || "$(echo "$avg_latency > 10" | bc)" -eq 1 ]]; then
        echo "Local Connection is BAD!"
        echo "Avg Latency: $avg_latency ms"
        echo -e "Packet loss: $packet_loss%\n"
    else
        echo -e "Local Connection is GOOD!"
        echo "Avg Latency: $avg_latency ms"
        echo -e "Packet loss: $packet_loss%\n"
    fi
}

# Test Internet Connection
test_internet() {
    local ping_output="$(ping -c 5 $remote_address)"
    local packet_loss="$(echo $ping_output | sed -E 's/.* ([0-9]+)% packet loss.*/\1/')"
    local avg_latency="$(echo $ping_output | cut -d"/" -f5)"
    
    if [[ "$packet_loss" -eq 100 ]]; then
        echo "Remote server $1 not reachable"
        exit 1
    elif [[ "$packet_loss" -gt 20 || "$(echo "$avg_latency > 300" | bc)" -eq 1 ]]; then
        echo "Internet Connection is BAD!"
        echo "Avg Latency: $avg_latency ms"
        echo -e "Packet loss: $packet_loss%"
    else
        echo -e "Internet Connection is GOOD!"
        echo "Avg Latency: $avg_latency ms"
        echo -e  "Packet loss: $packet_loss%\n"
    fi
}

test_dns_resolution() {
    resolve="$(dig +timeout=2 +retry=0 ifconfig.me | grep -i "timed out")"
    if [[ -n "$resolve" ]]; then
        echo "Name Resolution is BAD!"
    else
        echo "Name Resolution is GOOD!"
    fi
}

main() {
    test_lan
    test_internet
    test_dns_resolution
}

main "$1"

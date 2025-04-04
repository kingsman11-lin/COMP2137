#!/bin/bash

# Default values
VERBOSE=false
name=""
ip=""
hostEntry=""


# Function to print messages in verbose mode
verboseLog() {
    if $VERBOSE; then
        echo "$1"
    fi
}

# This section is ignoring TERM, HUP, and INT signals
    trap '' TERM HUP INT

# Log file creation for error logs
    logFile="scriptlogs.txt"

    logMessage() {
           local message="$1"
	   echo "$(datetime) - $message" >> "$logFile"
    }



# Function to update IP address
updatedIP() {
    local newIP=$1
    local interface=$(ip -o -4 route show to default | awk '{print $5}')
    local IPAddr=$(ip -o -4 addr show dev "$interface" | awk '{print $4}')

    if [ "$IPAddr" != "$newIP" ]; then

        verboseLog "Updating IP address to $newIP"
        sudo sed -i "/$IPAddr/d" /etc/hosts

        echo "$newIP $(hostname)"
    
# Network interface setup for new IP address    
network:
  version: 2
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$newIP/24]
EOF


        sudo netplan apply
        changedLog "IP address changed from $IPAddr to $newIP"
    else
        verboseLog "IP address is already $newIP. Try a new IP or continue to use the current one"
    fi
}



# Function to update /etc/hosts entry
updateHost() {
    local localHostName=$1
    local localHostIP=$2
    if ! grep -q "$localHostIP $localHostName" /etc/hosts; then
        verboseLog "Adding entry to /etc/hosts: $localHostIP $localHostName"
        echo "$localHostIP $localHostName"

        changedLog "Added host: $localHostIP $localHostName. Thank you"
    else
        verboseLog "Host entry already exists: $localHostIP $localHostName. Please try running the script again"
    fi
}


# Verbose characters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose)
            VERBOSE=true
            ;;
        -name)
            updateHostName "$1"
	    shift
            ;;
        -ip)
            updatedIP "$1"
	    shift
            ;;
	-hostentry)
	    hostEntry="$2"
	    shift
	    ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac


done

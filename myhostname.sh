#!/bin/bash

# default file to find ip addresses in for this script
myhostsfile=/etc/hosts
# find my ip in the hosts file when I have a hostname

echo "This script will fin the up for a hostname if it exists in $myhostsfile"


read -p "What hostname are you trying to lookup?" myhostname
if [ -z "$hostname" ]; then
	echo "I require a hostname to lookup"
	exit 1
fi

myipaddress="$(awk '/ $myhostname/{print $1}' $myhostsfile )"

if [ -z "$hostname" ]; then
	echo "I could not find that name in the $myhostsfile file"
	exit 1
fi

echo "The hostname '$myhostname' has the address $myipaddress in the $myhostsfile file"

# sed -i s/$myaddress/8.34.6.3/ $myhostsfile


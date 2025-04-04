#!/bin/bash

# This script runs the previous configure-host.sh script from the current directory.
# This will change 2 servers and update the local hosts file 
# /etc/hosts


scp configure-host.sh remoteadmin@server1-mgmt:/root
sshremoteadmin@server1-mgmt -- /root/configure-host.sh -name logHost -ip 192.168.16.3 -hostentry webhost 192.168.16.4
scp configure-host.sh remoteadmin@server2-mgmt:/root
sshremoteadmin@server1-mgmt -- /root/configure-host.sh -name logHost -ip 192.16.4 -hostentry loghost 192.168.16.3

# Script configure-host.sh entry
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry loghost 192.168.16.4



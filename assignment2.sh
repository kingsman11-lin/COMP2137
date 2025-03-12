#!/bin/bash


# Variables
hostName="server1"
hostFile="/etc/hosts"

addSudoUser="dennis"
userList=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

rsaKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"
sshDir="/home"

networkIF="192.168.16.21/24"




# Check and update /etc/hosts function
hostFileCheck() {
    echo "Checking /etc/hosts file for correct IP and hostname ->"
    
    if ! grep -q "$networkIF" "$hostFile"; then
        echo " Updating /etc/hosts with correct IP and hostName"
        echo "$networkIF $hostName" | sudo tee -a $hostFile > /dev/null
    else
        echo " /etc/hosts is already correct."
    fi
}

# Install apache & squid if not installed
installedSoftwareCheck() {
    echo " Checking if apache2 and squid are installed ->"

    # Install apache2 if not installed
    if ! dpkg -l | grep -q apache2; then
        echo "apache2 is not installed. Installing"
        sudo apt update && sudo apt install -y apache2
        sudo systemctl enable apache2
        sudo systemctl start apache2
        echo "apache2 installed and started."
    else
        echo "apache2 is already installed."
    fi

    # Install squid if not installed
    if ! dpkg -l | grep -q squid; then
        echo "squid is not installed. Installing"
        sudo apt install -y squid
        sudo systemctl enable squid
        sudo systemctl start squid
        echo "squid installed and started"
    else
        echo "squid is already installed"
    fi
}

# Check and create user accounts
usersCheckCreate() {
    echo "Checking user accounts ->"

    for USER in "${userList[@]}"; do
        if id "$USER" &>/dev/null; then
            echo " User $USER exists"
        else
            echo " Creating user $USER"
            sudo useradd -m -s /bin/bash "$USER"
            echo " User $USER created"
        fi

        # Create SSH directory if doesn't exist
        if [ ! -d "/home/$USER/ssh" ]; then
            echo " Creating SSH directory for user $USER"
            sudo mkdir -p /home/$USER/.ssh
            sudo chown "$USER":"$USER" /home/$USER/.ssh
            sudo chmod 755 /home/$USER/.ssh
        fi

        # Add public keys to authorized_keys
        if ! grep -q "$rsaKey" "/home/$USER/.ssh/authorized_keys"; then
            echo " Adding SSH key to $USER's authorized_keys"
            echo "$rsaKey" | sudo tee -a "/home/$USER/.ssh/authorized_keys" > /dev/null
            sudo chown "$USER":"$USER" /home/$USER/.ssh/authorized_keys
            sudo chmod 655 /home/$USER/.ssh/authorized_keys
        else
            echo " SSH key for user $USER already added"
        fi

        # Add user to sudo group if not already a member
        if [[ "$USER" == "$addSudoUser" ]]; then
            if ! groups "$USER" | grep -q "\bsudo\b"; then
                echo " Adding $USER to the sudo group"
                sudo usermod -aG sudo "$USER"
                echo " $USER added to sudo group"
            else
                echo " $USER is already in the sudo group"
            fi
        fi
    done
}

# Checks network config file, makes changes when needed
networkConfigCheck() {
    echo "Checking network config file /etc/netplan ->"
    configInterface=$(grep -A 2 "eth" /etc/netplan/* | grep "addresses")
    
    if [[ "$configInterface" != "$networkIF" ]]; then
        echo "Updating network interface configuration"
        sudo sed -i "s/\(addresses: \).*/\1$networkIF/" /etc/netplan/*
        sudo netplan apply
        echo "Network configuration updated"
    else
        echo "Network interface configuration is already correct"
    fi
}


# Starts running the script
echo "Starting assignment2.sh script ->"

networkConfigCheck
hostFileCheck
installedSoftwareCheck
usersCheckCreate

echo " Script completed. Feel free to run this script to check again. Thank you! "

#!/bin/bash
### --- Debian Bootstrap Seed ---

### VARS
update_upgrade=true
install_ssh=true
root_ssh_lockout=true
install_git=true
install_ansible=true

##
### START & PROMPT FOR SUDO PASSWARD
echo -e "\n --- STARTING - SYSTEM BOOTSTRAP SEED --- \n"

echo "Please enter your sudo password to continue:"
sudo -v

##
### NEW SYSTEM UPDATES
if [ "$update_upgrade" = true ]; then
    sudo apt update && sudo apt upgrade -y
else
    echo -e "\nSkipping - Update/Upgrade - see script vars for more info\n"
fi

##
### INSTALL - OPENSSH
if [ "$install_ssh" = true ]; then
    echo -e "\n - INSTALLING - openSSH - \n"

    ## Install OpenSSH server
    sudo apt install -y openssh-server

    ## Enable and start the SSH service
    sudo systemctl enable ssh
    sudo systemctl start ssh

    ## Optionally, Root SSH Login Disabled
    if [ "$root_ssh_lockout" = true ]; then
        sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
        echo -e "\n  Root SSH Log-in - Disabled"
    else
        echo -e "\n  Root SSH Log-in has not be altered"
    fi

    ## Restart the SSH service
    sudo systemctl restart ssh

    ## Complete Message
    echo -e "\n  OpenSSH installation and configuration complete.\n"
else
    echo -e "\n  Skipping OpenSSH installation and configuration.\n"
fi

##
### INSTALL - GIT
if [ "$install_git" = true ]; then
    echo -e "\n - INSTALLING - Git - \n"

    sudo apt install -y git

    ## Optionally, global Git settings
    #git config --global user.name "Your Name"
    #git config --global user.email "your.email@example.com"

    echo -e "\n  Git installation and configuration complete.\n"
else
    echo -e "\n  Skipping Git installation.\n"
fi

##
### INSTALL - ANSIBLE
if [ "$install_ansible" = true ]; then
    echo -e "\n - INSTALLING - Ansible - \n"

    sudo apt install -y ansible
    echo -e "\n  Ansible installation complete.\n"
else
    echo -e "\n  Skipping Ansible installation.\n"
fi

##
### DELETE IF IN A HOME FOLDER

## Get the script's current directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

## Get the user's home directory
HOME_DIR="$HOME"

## Check if the script is located in the home directory
if [[ "$SCRIPT_DIR" == "$HOME_DIR" ]]; then
    echo "Script removed after successful run."

    ## delete after execution
    rm -- "$0"
else
    echo "the script is located at $SCRIPT_DIR and has not been removed."
fi

##
### END MESSAGE
echo -e "\n --- DONE - BOOTSTRAP SEED --- \n\n"

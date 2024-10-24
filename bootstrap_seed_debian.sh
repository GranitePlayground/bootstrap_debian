#!/bin/bash
### --- Debian Bootstrap Seed ---

### VARS
update_upgrade=true
install_ssh=true
root_ssh_lockout=true
install_git=true
install_ansible=true
# Replace with your SSH public key
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCp2S2vS0PZnw7hCBoEo+N4CXiw0rfz2mBPxTHZ4jglqizM0d4ImT8FaEzfTFmmdVBHkt1mNHhexRbEK2lqA+C1E82ANHYu+tHG+O0ct7QOUJ2E7GaacybUiskco1l24fRh5wDvs+PoEPyGGJylN1xd7ESvDN5f/J3KKvnww7vPg7zpNYJeC1c6QXVwmCm7bC/aBjMC+N4jyl5t7AkYmU1wWcLmVhJzOI3jm4iuD4jiniMupdl+y0prI14TIY+WjvafdknRda8I44FagRV7uzFutBF1NongB23GHulQHOZgK+TF1qdu8ozjV9r4aC5uUmPv+bQ1brhtZiJdkbEVLFXFdDIKys+HvivU2plENpbSbG788BEgXCq1CxdWLFXCOlanFhiAT1Xgxq73j4XcWIaG9YDvg9qjzX936OfJ6YetQEXUYcKwr6YH4YRQt+b1befH8FcREOuLmqmR+qUfrAbdlWtaNp0w4Ws4DXPXcna4Kvf26z+NhYLagC4BeICqf9M= laverne@Laverne.local"

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
### DEPLOY - SSH PUBLIC KEY
## Ensure .ssh directory and public key present
mkdir -p ~/.ssh && echo "$SSH_PUBLIC_KEY" >>~/.ssh/authorized_keys
## Set directory and file permissions
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
## Ensure ownership ~/.ssh/ and authorized_keys file
chown -R $USER:$USER /home/$USER/.ssh
## Restart SSH service
systemctl restart ssh
echo "SSH public key added successfully."

##
### DELETE SCRIPT - IF IN A HOME FOLDER
## Get the script's current directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
## Get the user's home directory
HOME_DIR="$HOME"
## Check if the script is located in the home directory
if [[ "$SCRIPT_DIR" == "$HOME_DIR" ]]; then
    echo -e "\n  The script ran successfully and will be removed."
    ## delete after execution
    rm -- "$0"
else
    echo -e "\n  the script is located at $SCRIPT_DIR and has not been removed."
fi

##
### END MESSAGE
echo -e "\n --- SYSTEM BOOTSTRAP SEED - COMPLETED --- \n\n"

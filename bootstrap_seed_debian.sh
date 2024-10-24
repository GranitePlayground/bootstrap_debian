#!/bin/bash
set -e
### --- Debian Bootstrap Seed ---

### - VARS -
UPDATE_UPGRADE=true
INSTALL_SSH=true
ROOT_SSH_LOCKOUT=true
INSTALL_GIT=true
INSTALL_ANSIBLE=true
ADD_PUBLIC_KEY=true
SSH_PUBLIC_KEY= # insert public key here.

### - FUNCTIONS -
update_system() {
    echo -e "\n  Updating and upgrading system...\n"
    sudo apt update && sudo apt upgrade -y
    echo -e "\n  System is up-to-date.\n"
}

install_ssh() {
    echo -e "\n  Installing OpenSSH server...\n"
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
    if [ "$ROOT_SSH_LOCKOUT" = true ]; then
        sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
        echo -e "\n  Root SSH log-in has been disabled."
    fi
    sudo systemctl restart ssh
    echo -e "\n  OpenSSH installation complete.\n"

}

add_ssh_key() {
    echo -e "\n  Adding ssh public key..."
    mkdir -p ~/.ssh
    echo "$SSH_PUBLIC_KEY" >>~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chown -R $USER:$USER ~/.ssh
    sudo systemctl restart ssh
    echo -e "\n  SSH public key added successfully.\n"
}

install_git() {
    echo -e "\n  Installing Git...\n"
    sudo apt install -y git
    echo -e "\n  Git installation complete.\n"
}

install_ansible() {
    echo -e "\n  Installing Ansible...\n"
    sudo apt install -y ansible
    echo -e "\n  Ansible installation complete.\n"
}

cleanup_script() {
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    HOME_DIR="$HOME"

    if [[ "$SCRIPT_DIR" == "$HOME_DIR" ]]; then
        rm -- "$0"
        echo -e "\n  The script has been removed.\n"
    fi
}

### - MAIN -
echo -e "\n --- STARTING - SYSTEM BOOTSTRAP SEED --- \n"
echo "Please enter your sudo password to continue:"
sudo -v # Prompt for sudo password

[ "$UPDATE_UPGRADE" = true ] && update_system
[ "$INSTALL_SSH" = true ] && install_ssh
[ "$ADD_PUBLIC_KEY" = true ] && add_ssh_key
[ "$INSTALL_GIT" = true ] && install_git
[ "$INSTALL_ANSIBLE" = true ] && install_ansible
cleanup_script

echo -e "\n --- SYSTEM BOOTSTRAP SEED - COMPLETED --- \n\n"

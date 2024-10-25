#!/bin/bash
set -e
### --- Debian Bootstrap Seed ---

#
### - VARS -
APT_UPDATE_UPGRADE=true
INSTALL_ANSIBLE=true

INSTALL_GIT=true
GIT_USER=""       ## $USER
GIT_USER_EMAIL="" ## email here

SSH_ENABLE=true
SSH_ROOT_LOCKOUT=true
## Public SSH Key: 2 Optioins - local hard coded - or - dynamic fetch -
SSH_ADD_PUBLIC_KEY=true
## Hard-coded ssh_key
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCp2S2vS0PZnw7hCBoEo+N4CXiw0rfz2mBPxTHZ4jglqizM0d4ImT8FaEzfTFmmdVBHkt1mNHhexRbEK2lqA+C1E82ANHYu+tHG+O0ct7QOUJ2E7GaacybUiskco1l24fRh5wDvs+PoEPyGGJylN1xd7ESvDN5f/J3KKvnww7vPg7zpNYJeC1c6QXVwmCm7bC/aBjMC+N4jyl5t7AkYmU1wWcLmVhJzOI3jm4iuD4jiniMupdl+y0prI14TIY+WjvafdknRda8I44FagRV7uzFutBF1NongB23GHulQHOZgK+TF1qdu8ozjV9r4aC5uUmPv+bQ1brhtZiJdkbEVLFXFdDIKys+HvivU2plENpbSbG788BEgXCq1CxdWLFXCOlanFhiAT1Xgxq73j4XcWIaG9YDvg9qjzX936OfJ6YetQEXUYcKwr6YH4YRQt+b1befH8FcREOuLmqmR+qUfrAbdlWtaNp0w4Ws4DXPXcna4Kvf26z+NhYLagC4BeICqf9M= laverne@Laverne.local" # insert public key here.
## or URL fetch SSH public key dynamically (SSH_PUBLIC_KEY President-Over SSH_KEY_URL)
SSH_KEY_URL="" ## URL for dynamic public ssh_key

#
### - FUNCTIONS -
check_dependencies() {
    echo -e "\n  Checking Dependancies...\n"
    command -v apt >/dev/null 2>&1 || {
        echo >&2 "apt is required but not installed. Aborting."
        exit 1
    }
    command -v sudo >/dev/null 2>&1 || {
        echo >&2 "sudo is required but not installed. Aborting."
        exit 1
    }
    command -v curl >/dev/null 2>&1 || {
        echo >&2 "curl is required but not installed. Aborting."
        exit 1
    }
    echo -e "\n  Dependancies passed.\n"
}

update_system() {
    echo -e "\n  Updating and upgrading system...\n"
    sudo apt update && sudo apt upgrade -y
    echo -e "\n  System is up-to-date.\n"
}

install_ssh() {
    echo -e "\n  Installing OpenSSH server...\n"
    sudo apt install -y openssh-server
    [[ "$SSH_ENABLE" = true ]] && sudo systemctl enable ssh
    sudo systemctl start ssh
    [[ "$SSH_ROOT_LOCKOUT" = true ]] && {
        sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
        echo -e "\n  Root SSH log-in has been disabled."
    }
    sudo systemctl restart ssh
    echo -e "\n  OpenSSH installation complete.\n"

}

add_ssh_key() {
    echo -e "\n  Adding ssh public key..."
    mkdir -p ~/.ssh

    ## SSH Public Key Hardcoaded or Managment File
    # Use hardcoded key if provided, otherwise fetch from URL
    [[ -n "$SSH_PUBLIC_KEY" ]] && echo "Using hardcoded SSH public key." && echo "$SSH_PUBLIC_KEY" >>~/.ssh/authorized_keys
    [[ -z "$SSH_PUBLIC_KEY" && -n "$SSH_KEY_URL" ]] && echo "Fetching SSH public key from $SSH_KEY_URL" && curl -fsSL "$SSH_KEY_URL" >>~/.ssh/authorized_keys
    # If no key was added, show error
    [[ -z "$SSH_PUBLIC_KEY" && -z "$SSH_KEY_URL" ]] && echo "Error: No SSH public key provided or URL to fetch from." >&2 && return 1

    #### TEST ABOVE THEN REMOVE #####
    #echo "$SSH_PUBLIC_KEY" >>~/.ssh/authorized_keys
    ## OR...below to point at a management file
    #echo "Fetching SSH public key from $SSH_KEY_URL"
    #curl -fsSL "$SSH_KEY_URL" >> ~/.ssh/authorized_keys

    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chown -R $USER:$USER ~/.ssh
    sudo systemctl restart ssh
    echo -e "\n  SSH public key added successfully.\n"
}

install_git() {
    echo -e "\n  Installing Git...\n"
    sudo apt install -y git

    ## Optionally, global Git settings
    [[ -n "${GIT_USER// /}" && "$GIT_USER" != \#* ]] && git config --global user.name "${GIT_USER}"
    [[ -n "${GIT_USER_EMAIL// /}" && "$GIT_USER_EMAIL" != \#* ]] && git config --global user.email "${GIT_USER_EMAIL}"

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

    [[ "$SCRIPT_DIR" == "$HOME_DIR" ]] && {
        rm -- "$0"
        echo -e "\n  The script has been removed.\n"
    }
}

#
### - MAIN -
echo -e "\n --- STARTING - SYSTEM BOOTSTRAP SEED --- \n"
echo "Please enter your sudo password to continue:"
sudo -v # Prompt for sudo password

[ "$APT_UPDATE_UPGRADE" = true ] && update_system
install_ssh
[ "$SSH_ADD_PUBLIC_KEY" = true ] && add_ssh_key
[ "$INSTALL_GIT" = true ] && install_git
[ "$INSTALL_ANSIBLE" = true ] && install_ansible
cleanup_script

echo -e "\n --- SYSTEM BOOTSTRAP SEED - COMPLETED --- \n\n"

#!/bin/bash

###########################################################
#
# Program name: provision-environment.sh
#
# Author: Chase Weyer
#
# Purpose: To provision a local development environment in by 
# following these steps:
#
# Get Environment: Gather a command line argument to get the 
# environment name. This will determine the appropriate commands
# to run during the install steps.
#
# Evironment Preparation: To prepare the system for additional 
# installs by updating the local repos and upgrading any installs 
# that need it.
#
# Install Google Chrome: To install the web browser Google 
# Chrome so that it can be used upon start of the system.
#
# Install VS Code: To install the stable version of VS code 
# for development purposes.
###############################################################
function fail-step {
    # If step fails, provide messsage and abort
    if [ $? -eq 1 ];
    then
        echo "** Command failed to run **"
        echo "** Aborting Provising **"
        exit 1
    fi
}

function environment-preparation {
    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update local repo
        echo "** Updating Apt Repo **"
        sudo apt-get update -y
        fail-step

        # Upgrade packages
        echo "** Upgrading packages **"
        sudo apt-get upgrade -y
        fail-step

    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        echo "** Updating Yum Repo and Ugrade Programs **"
        sudo yum update -y
        fail-step
    fi
}

function install-google-chrome {
    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update Apt Repo
        echo "** Updating Apt Repo **"
        sudo apt-get update -y
        fail-step

        # Install wget
        echo "** Installing wget **"
        sudo apt-get install wget -y
        fail-step

        # Download Google Chrome binary
        echo "** Downloading Google Chrome Debian Binary **"
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        fail-step

        # Install Google Chrome
        echo "** Installing Google Chrome **"
        sudo dpkg -i google-chrome-stable_current_amd64.deb

        # Gather dependencies if google chrome install fail becuase of dependencies
        if [ $? -eq 1 ];
        then
            sudo apt-get -f install -y
            fail-step
        fi

        # Remove downloaded binary
        echo "** Remove Google Chrome binary **"
        rm -f google-chrome-stable_current_amd64.deb
        fail-step
    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        # Install wget
        echo "** Installing wget **"
        sudo yum install wget -y
        fail-step

        # Download Google Chrome binary
        echo "** Downloading Chrom RPM binary"
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
        fail-step

        # Install Google Chrome
        echo "** Installing Google Chrome **"
        sudo yum localinstall google-chrome-stable_current_x86_64.rpm -y
        fail-step

        echo "** Remove Google Chrome Binary**"
        rm -rf ~/google-chrome-stable_current_x86_64.rpm
        fail-step
    fi
}

function install-git {
    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update the local repos before downloading
        echo "** Installing Git **"
        sudo apt-get update
        fail-step

        sudo apt-get install gcc git -y
        fail-step

    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        echo "** Installing Git **"
        sudo yum install gcc git -y
        fail-step
    fi
}

function install-vs-code {

    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update the local repos before downloading
        echo "** Updating Apt Repo **"
        sudo apt-get update -y
        fail-step

        # Install the classic build of VS Code
        echo "** Install VS Code through Snap Store **"
        sudo snap install code --classic
        fail-step

        # Install Docker and Remote: Containers extensions for VS Code
        echo "** Installing Docker and Remote: Containers extensions for VS Code"
        code --install-extension ms-azuretools.vscode-docker
        fail-step
        code --install-extension ms-vscode-remote.remote-containers
        fail-step

    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        echo "** Add VS Code to Yum Repo"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        fail-step
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        fail-step

        echo "** Check that the Yum Repo update with VS Code Repo"
        sudo yum check-update
        fail-step
        
        echo "** Installing VS Code Stable build **"
        sudo yum install code -y
        fail-step
    fi
}

function install-docker {

    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update local repos before downloading
        echo "** Updating Apt Repo before installing Docker dependencies **"
        sudo apt-get update -y
        fail-step

        # Install dependencies for docker
        echo "** Installing Docker Dependencies **"
        sudo apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
        fail-step
        
        # Download keys for Docker download
        echo "** Adding GPG Keys for Docker **"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        fail-step

        # Add the Docker repo to the local Apt repo
        echo "** Adding the Docker repo to the local Apt repo **"
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        fail-step
        # Update Apt repo before downloading Docker
        echo "** Updating Apt Repo before installing Docker"
        sudo apt-get update
        fail-step

        # Download Docker
        echo "** Installing Docker CE **"
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y
        fail-step

        # Add vagrant user to docker group
        # Will allow vagrant user to use docker without sudo
        echo "** Adding vagrant user to Docker group **"
        sudo usermod -aG docker vagrant
        fail-step
    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        # Install dependencies needed for docker to run
        echo "** Installing dependencies for Docker **"
        sudo yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2
        fail-step

        # Add the docker repo to the Yum repository
        echo "** Adding the Docker Repo to the Yum Repo **"
        sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
        fail-step

        echo "** Installing Docker CE **"
        sudo yum install docker-ce docker-ce-cli containerd.io -y
        fail-step
    fi

    # Enable Docker upon startup
    echo "** Enabling Docker upon startup **"
    sudo systemctl enable docker
    fail-step
}

function install-gui {

    if [[ "$ENVIRONMENT" == 'ubuntu' ]];
    then
        echo "** Installing Gnome Desktop **"
        sudo apt-get install ubuntu-desktop -y
        fail-step
    elif [[ "$ENVIRONMENT" == 'centos' ]];
    then
        echo "** Installing KDE Desktop **"
        sudo yum groupinstall 'KDE' 'X Window System' -y
        fail-step

        echo "** Enabling KDE Desktop Upon Startup **"
        sudo systemctl set-default graphical.target
        fail-step
    fi
}

# Run steps in order

environment-preparation
install-google-chrome
install-git
install-vs-code
install-docker
install-gui
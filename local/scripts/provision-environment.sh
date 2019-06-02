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
function environment-preparation {
    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update local repo
        echo "** Updating Apt Repo **"
        sudo apt-get update -y

        # Upgrade packages
        echo "** Upgrading packages **"
        sudo apt-get upgrade -y
    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        echo "** Updating Yum Repo and Ugrade Programs"
        sudo yum update -y
    fi
}

function install-google-chrome {
    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update Apt Repo
        echo "** Updating Apt Repo **"
        sudo apt-get update -y

        # Install wget
        echo "** Installing wget **"
        sudo apt-get install wget -y

        # Download Google Chrome binary
        echo "** Downloading Google Chrome Debian Binary **"
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

        # Install Google Chrome
        echo "** Installing Google Chrome **"
        sudo dpkg –i google-chrome-stable_current_amd64.deb

        # Remove downloaded binary
        echo "** Remove Google Chrome binary **"
        rm -rf google-chrome-stable_current_amd64.deb
    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        # Install wget
        echo "** Installing wget **"
        sudo yum install wget -y

        # Download Google Chrome binary
        echo "** Downloading Chrom RPM binary"
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

        # Install Google Chrome
        echo "** Installing Google Chrome **"
        sudo yum localinstall google-chrome-stable_current_x86_64.rpm -y

        echo "** Remove Google Chrome Binary**"
        rm -rf google-chrome-stable_current_x86_64.rpm
    fi
}

function install-vs-code {

    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update the local repos before downloading
        echo "** Updating Apt Repo **"
        sudo apt-get update -y

        # Install the classic build of VS Code
        echo "** Install VS Code through Snap Store **"
        sudo snap install code --classic

    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        echo "** Add VS Code to Yum Repo"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

        echo "** Check that the Yum Repo update with VS Code Repo"
        sudo yum check-update
        
        echo "** Installing VS Code Stable Build **"
        sudo yum install code -y
    fi
}

function install-docker {

    if [[ "$ENVIRONMENT" == 'ubuntu' ]]
    then
        # Update local repos before downloading
        echo "** Updating Apt Repo before installing Docker dependencies **"
        sudo apt-get update -y

        # Install dependencies for docker
        echo "** Installing Docker Dependencies **"
        sudo apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
        
        # Download keys for Docker download
        echo "** Adding GPG Keys for Docker **"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        # Add the Docker repo to the local Apt repo
        echo "** Adding the Docker repo to the local Apt repo **"
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        
        # Update Apt repo before downloading Docker
        echo "** Updating Apt Repo before installing Docker"
        sudo apt-get update

        # Download Docker
        echo "** Installing Docker CE **"
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y
    elif [[ "$ENVIRONMENT" == 'centos' ]]
    then
        # Install dependencies needed for docker to run
        echo "** Installing dependencies for Docker **"
        sudo yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2

        # Add the docker repo to the Yum repository
        echo "** Adding the Docker Repo to the Yum Repo **"
        sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo

        echo "** Installing Docker CE **"
        sudo yum install docker-ce docker-ce-cli containerd.io -y
    fi

    # Enable Docker upon startup
    echo "** Enabling Docker upon startup **"
    sudo systemctl enable docker
}

# Exit when any command failes
set -e

# Run steps in order

environment-preparation
install-google-chrome
install-vs-code
install-docker
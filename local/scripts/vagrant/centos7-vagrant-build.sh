#!/bin/bash

############################################################
#
# Program name: centos7-vagrant-build.sh
#
# Author: Chase Weyer
#
# Purpose: To install the necessary provisioning scripts for
# a Centos 7 VM that will be deployed through vagrant on a 
# host OS. As such, it will include an export variable
# to notify the provision-environments.sh script to install
# Centos commands, execute the provisioners
# for the evironment build and KDE GUI, and add vagrant user to 
# Docker.
#
############################################################

echo "** Export Centos Environment **"
export ENVIRONMENT=centos

echo "** Allow install scripts to be executable **"
sudo chmod u+x /home/vagrant/scripts/*.sh

echo "** Run Provisioning scripts **"
. /home/vagrant/scripts/provision-environments.sh -e centos
. /home/vagrant/scripts/install-kde-centos.sh
. /home/vagrant/scripts/install-virtualbox-guest-additions-centos-7.sh
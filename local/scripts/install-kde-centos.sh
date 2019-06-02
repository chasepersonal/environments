#!/bin/bash

############################################################
#
# Program name: install-kde-centos.sh
#
# Author: Chase Weyer
#
# Purpose: To install a kde gui in a centos environment and
# enable the gui on startup
#
#
############################################################

function install-kde-desktop {
    echo "** Updating YUM cache **"
    sudo yum makecache

    echo "** Installing KDE Desktop **"
    sudo yum groups install "KDE Plasma Workspaces" -y
}

function enable-kde-desktop {

    echo "** Enabling KDE Desktop Upon Startup **"
    sudo systemctl set-default graphical.target
}

# Install KDE and set it as the GUI upon startup
install-kde-desktop
enable-kde-desktop
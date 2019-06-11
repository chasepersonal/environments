#!/bin/bash

############################################################
#
# Program name: install-virtualbox-guest-additions-centos-7.sh
#
# Author: Chase Weyer
#
# Purpose: To install virutalbox guest additions in a CentOS
# 7 Environment. 
#
#
############################################################

function install-prereqs {

    # Installing pre-requisites for Guest Additions
    echo "** Install VirtualBox Guest Additions Dependencies **"
    sudo yum groupinstall "Development Tools" -y
    sudo yum install perl gcc dkms kernel-devel kernel-headers make bzip2 -y

    # Sync distros in case they are out of sync
    echo "** Sync yum distro in case some packages are out of sync **"
    sudo yum distro sync -y

    echo "** Export Kernel Version for Install **"
    export KERN_DIR=/usr/src/kernels/$(uname -r)
}

function install-guest-additions {

    # Download VirutalBox Guest Additions
    echo "** Download VirtualBox Guest Additions **"
    sudo cd /media
    sudo wget http://download.virtualbox.org/virtualbox/5.2.30/VBoxGuestAdditions_5.2.30.iso

    echo "** Mount Temporary Drive **"
    cd /
    sudo mount -t iso9660 -o loop /media/VBoxGuestAdditions_5.2.30.iso /mnt/iso

    echo "** Install Guest Additions **"
    sudo cd /mnt/iso
    sudo ./VBoxLinuxAdditions.run
}

function clean-up {

    # Remove temporary drive
    echo "** Unmount temporary drive **"
    sudo cd /
    sudo umount /mnt/iso
    sudo rm /media/VBoxLinuxAdditions_5.2.30.iso
}

# Execute steps

install-prereqs
install-guest-additions
clean-up
# Raspberry Pi 4

The files in this directory will contain steps to provision a new Rapsberry Pi cluster.

Though the focus will be to prepare it to be a k3s cluster, the steps in this directory are more generic and can be applied to Raspberry Pi builds that aren't k3s related.

The purpose of this directory is to house Ansible playbooks that will help automate the provisiong on a Raspberry Pi cluster and ensure that the cluster is as homogoneous with it's packages and storage layout as much as possible.


## Executing preparation install

The following playbook can be run to perform the following operations on the Raspberry Pi cluster machines:

* Configure storage to use USB for main files
* Set up networking to use static Ethernet and Wifi IP's
* Update and install necessary packages
    * rbd-nbd for eventual Ceph storage and ansible for the master
* Ensure master has the package check crontab
    * this will ensure all nodes have the necessary packages daily and they are updated in a timely manner

`ansible-playbook --private-key ~/.ssh/pi_key -i /bare-metal/raspberry-pi/inventory/inventory /bare-metal/raspberry-pi/pi-prep.yml`

## References

The following articles were referenced during the creation of this directory:

https://www.tomshardware.com/news/boot-raspberry-pi-from-usb,39782.html

https://docs.ansible.com/ansible/latest/

https://thepihut.com/blogs/raspberry-pi-tutorials/how-to-give-your-raspberry-pi-a-static-ip-address-update

https://pimylifeup.com/raspberry-pi-dns-settings/

https://stackoverflow.com/questions/42348098/how-to-create-a-new-partition-with-ansible


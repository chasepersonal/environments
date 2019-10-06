# Harbor

This repository will contain all of the necessary steps to install the Harbor Docker Registry in a semi-automated fashion.

It will use a combination of a shell script and an ansible-playbook to launch an AWS instance and provision it with all of the necessary files and services needed to successfully launch a VMWare Harbor Docker Registry.

The following tutorials/help pages were used during the creation of these files:

Harbor Install: 

https://computingforgeeks.com/how-to-install-harbor-docker-image-registry-on-centos-debian-ubuntu/

Ansible Playbook construction:
https://docs.ansible.com/

Harbor Service creation:

https://github.com/docker/compose/issues/4266
## Vagrant

This folder will contain Vagrantfiles for automated builds of VM's designed for container development if one does not wish to use Docker on their host OS. These Vagrantfiles will build a Linux environment based on a specific Linux flavor. At the moment, these Vagrantfiles include builds for the following environments:

`Centos 7`

This build will also include the reload plugin as some of the provisioning steps require a restart to take affect.

The plugin will need to be installed to your local vagrant instance using the following:

`vagrant plugin install vagrant-reload`
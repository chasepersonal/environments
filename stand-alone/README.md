# Stand-Alone

This repository will contain all of the necessary files to deploy stand alone cloud infrastructure

In contrast to the Kubernetes infrastructure, this will be for small numbers of machines that will either need to be stand alone or for deploying a small microservice that doesn't need the full robust features of a Kubernetes deployment.

## Ansible

These deployments will use Ansible to deploy cloud instances

### deploy-cloud-instance.yml

This will utilize Ansible to deploy VM(s) on a cloud provider.

It is only mean to deploy the VM.

It must be provisioned through another file.

Playbook can be run with the following command. Example is using AWS as the cloud provider:

`ansible-playbook --ask-vault-pass deploy-cloud-instance.yml --extra-vars="cloud=aws"`

### harbor-provision-only.yml

This will utilize Ansible to provision a VMWare Harbor Registry.

It's intended purpose is to provision a VM that has already been deployed.

Playbook can be run with the following command.

`ansible-playbook --ask-vault-pass -i inventory harbor-provision-only.yml --extra-vars="user=user"`

A user will need to be indicated depending on the user name you wish to install Harbor under.

You will also need to include the name of the machine under [harbor-server] group in the inventory provided

### harbor-provision-with-instance.yml

This will utilize Ansible to deploy a VM, or VM's, and provision it with the tools needed to run a VMWare Harbor Registry.

It will utilize steps from both the aforementioned files.

## Terraform

This will house deployments that will utilize Terraform

# About

The following tutorials/help pages were used during the creation of these files:

Harbor Install: 

https://computingforgeeks.com/how-to-install-harbor-docker-image-registry-on-centos-debian-ubuntu/

Ansible Playbook construction:

https://docs.ansible.com/

Harbor Service creation:

https://github.com/docker/compose/issues/4266
# DigitalOcean - k3s

This repository will contain all the necessary files to install a k3s cluster in DigitalOcean.

k3s is a lightweight Kubernetes installation from the Rancher team that is mean to run on infrastructure with limited resources.

More about k3s can be found on Rancher's official site:

https://rancher.com/docs/k3s/latest/en/

To atuomate this deployment as much as possible, this deployment will consist of the following:

* Terraform Deployment to configure the infrastructure
* Ansible configuration to provision the infrastructure
* host-generator shell file to convert terraform ips to ansible host file

`ansible-playbook -i hosts --vault-id aws@prompt --vault-id harbor@prompt --vault-id user@prompt deploy-k3s.yml --extra-vars="user=dev"`
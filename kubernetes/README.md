# Kubernetes

The following directory contains build files for creating Kubernetes deployments across multiple cloud providers and raspberry pi environments in a standardized way utilizing a combination of Kubernetes deployment tools, Ansible, and Terraform.

The environment will also contain the following Helm deployments:

Contour: For ingress deployments

MetalLB: For Load Balancing (Rasperry Pi deployments only)

Cert-Manager: For Handling certificates for web applications

Rook-Ceph: For distributing block and s3 storage for future kubernetes deployemnts

Harbor: For handling Docker and Helm deployments on the platform

## k3s

The following Ansible playbook will deploy a k3s deployment on any cloud provider and rapsberry pi environments using terraform for helm and/or machine build depending on the environment being provisioned:

```
deploy-k3s.yml
```

### k3s on AWS

To deploy a k3s cluster on AWS, run the k3s deployment playbook as follows:

```
ansible-playbook /environments/kubernetes/deploy-k3s.yml --extra-vars --vault-id harbor@prompt --vault-id k3s@prompt -- vault-id k3s-aws@prompt "build=aws user=core"
```

### k3s on Pi

To deploy a k3s cluster on a Raspberry Pi, run the k3s deployment playbook as follows:

```
ansible-playbook -i /environments/kubernetes/inventory/pi/inventory /environments/kubernetes/deploy-k3s.yml --extra-vars --vault-id pi@prompt --vault-id harbor@prompt --vault-id k3s@prompt -- vault-id pi@prompt "build=pi user=pi"
```

## Kops

The following Ansible playbook will deploy a full Kubernetes deployment using Kops on any cloud provider using terraform for helm and for machine level infrastructure builds depending on the environment being provisioned:

```
deploy-kops-cluster.yml
```

### Kops on AWS

To deploy a kops cluster on AWS, run the Kops deployment playbook as follows:

```
ansible-playbook -i /environments/kubernetes/deploy-kops-cluster.yml --extra-vars "build=aws"
```
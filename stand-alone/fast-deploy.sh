#!/bin/bash
# Provision harbor server only
function provision-harbor-server-only {
    echo "** Running Ansible Playbook to provision the Harbor server **"
    ansible-playbook --ask-vault-pass -i inventory harbor-provision.yml -e@/vars/harbor/filesharbor-creds.yml /var/harbor/harbor-vars.yml
}

function provision-cloud-only {
    ansible-playbook deploy-cloud-instance --extra-vars="cloud="
}

function provision-harbor-and-cloud {
    ansible-playbook deploy-cloud-instance.yml --extra-vars="cloud="
    ansible-playbook --ask-vault-pass -i inventory harbor-provision.yml -e@/vars/harbor/filesharbor-creds.yml /var/harbor/harbor-vars.yml 
}
# Main functions
#provision-harbor-server-only
#provision-cloud-only
#provision-harbor-and-cloud
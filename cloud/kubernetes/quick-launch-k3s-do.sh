#!/bin/bash

# Quickly launch a k3s instance on digitalocean

ansible-playbook \
--vault-id do@prompt \
--vault-id user@prompt \
--vault-id aws@prompt \
--vault-id k3s@prompt \
--vault-id harbor@prompt \
deploy-k3s-do.yml \
--extra-vars="user=dev"
#!/bin/bash

# Quickly launch a k3s instance on RaspberryPi

ansible-playbook \
--vault-id aws@prompt \
--vault-id k3s@prompt \
--vault-id harbor@prompt \
deploy-k3s-pi.yml
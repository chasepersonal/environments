#!/bin/bash

# Quickly configure and launch a k3s instance on RaspberryPi

ansible-playbook \
-i inventory/pi/inventory \
--vault-id aws@prompt \
--vault-id k3s@prompt \
deploy-k3s.yml
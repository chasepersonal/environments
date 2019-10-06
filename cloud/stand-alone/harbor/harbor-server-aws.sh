#!/bin/bash

# Import .json variables
function environment-variables {
    ENVIRONMENT=$(cat harbor-aws.json | jq '.environment');
    ANSIBLE=$(cat harbor-aws.json | jq .'ansible');
    IMAGE_ID=$(echo "$ENVIRONMENT" | jq -r '.image-id');
    NAME=$(echo "$ENVIRONMENT" | jq -r '.name' );
    COUNT=$(echo "$ENVIRONMENT" | jq -r '.count' );
    INSTANCE_TYPE=$(echo "$ENVIRONMENT" | jq -r '.instance-type' );
    KEY_NAME=$(echo "$ENVIRONMENT" | jq -r '.key-name');
    SG_ID=$(echo "$ENVIRONMENT" | jq -r '.sg-id');
    SB_ID=$(echo "$ENVIRONMENT" | jq -r '.sb-id');
    DOMAIN=$(echo "$ENVIRONMENT" | jq -r '.domain');
    EMAIL=$(echo "$ENVIRONMENT" | jq -r '.email');
}

# Deploy AWS EC2 Instance
function deploy-harbor-server {
    aws ec2 run-instances \
        --image-id $IMAGE_ID \
        --tag Name=$NAME \
        --count $COUNT \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-group-ids $SG_ID \
        --subnet-id $SB_ID \
        --block-device-mappings file://mapping.json >> instance-output.json
}

function get-public-dns {
    $INASTANCE_ID=$(cat instance-output.json | jq -r ".Instances[0].InstanceId")

    echo "** Gathering Public DNS of newly created machine **"
    
    $PUBLIC_DNS=""

    # If public dns doesn't populate, keep running aws command
    while [ $PUBLIC_DNS == "" ];
    do
        $PUBLIC_DNS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | jq ".Reservations[0].Instances[0].PublicDnsName")
    done

    echo "** Public DNS: $PUBLIC_DNS **"
    echo "** Please update this with your DNS provider for custom routing **"
    echo "** This change will need to be made for harbor to successfully install **"
    read -p "Are you ready to continue? (Please indicate with a Y or y)" choice
    case "$choice" in 
        y|Y ) echo "yes";;
        * ) echo "Invalid choice: Please indicate your readiness with a Y or y";;
    esac
}

function provision-harbor-server {

    echo "** Running Ansible Playbook to provision the Harbor server **"
    ansible-playbook --ask-vault-pass -i inventory harbor-provision.yml -e@harbor-creds.yml harbor-vars.yml
}

# Main functions
environment-variables
deploy-harbor-server
get-public-dns
provision-harbor-server
#!/bin/bash

###########################################################
#
# Program name: delete-env.sh
#
# Author: Chase Weyer
#
# This script is used to automatically delete a Kubernetes
# environment on the Google Kubernetes Engine (GKE). It will 
# take in a .json configuration file for what GKE needs in
# order to identify the cluster for deletion. 
#
############################################################

function environment-variables {
    echo "** Parsing environment variables from json file**"
    ENVIRONMENT=$(cat ../gcp.json | jq '.environment');
    PROJECT_NAME=$(echo "$ENVIRONMENT" | jq -r '.projectname');
    CLUSTER_NAME=$(echo "$ENVIRONMENT" | jq -r '.clustername');
    ZONE_NAME=$(echo "$ENVIRONMENT" | jq -r '.zone');
    NETWORK_NAME=$(echo "$ENVIRONMENT" | jq -r '.network');
    AUTH=$(echo "$ENVIRONMENT" | jq -r '.auth');
    SUBNET_NAME=$(echo "$ENVIRONMENT" | jq -r '.subnet');
    POD_SUBNET=$(echo "$ENVIRONMENT" | jq -r '.podsubnet');
    SERVICE_SUBNET=$(echo "$ENVIRONMENT" | jq -r '.servicesubnet');
    REGION=$(echo "$ENVIRONMENT" | jq -r '.region');
}

function login {
    echo "** Logging into the GCP Platform **"
    gcloud auth activate-service-account --key-file=$AUTH
}

function set-project {
    echo "** Setting project and compute zone **"
    gcloud config set project $PROJECT_NAME
    gcloud config set compute/zone $ZONE_NAME
}

function delete-cluster {
    echo "** Deleting cluster **"
    gcloud container clusters delete $CLUSTER_NAME --quiet
}

function delete-network {

    # Delete static ips
    echo "** Deleting static ip **"
    gcloud compute addresses delete $SUBNET_NAME \
    --region=$REGION \
    --quiet

    # Delete all subnets
    echo "** Deleting subnets **"
    gcloud compute networks subnets delete $SUBNET_NAME \
    --region=$REGION \
    --quiet

    # Delete overall network
    echo "** Deleting VPC Network **"
    gcloud compute networks delete $NETWORK_NAME --quiet
}
# Exit if one of the commands fails
set -e

# Import Environment Variables
environment-variables

# Login, set the project, delete the cluster, delete the network
login
set-project
delete-cluster
delete-network
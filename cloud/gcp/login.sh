#!/bin/bash

###########################################################
#
# Program name: login.sh
#
# Author: Chase Weyer
#
# This script is used to automatically login to a
# preconfigured GKE enviornment so that the kubectl command
# can be utilized with the GKE environment.
#
############################################################

# Get environment variables
function environment-variables {
    
    ENVIRONMENT=$(cat ../gcp.json | jq .'environment');
    PROJECT_NAME=$(echo "$ENVIRONMENT" | jq -r '.projectname');
    AUTH=$(echo "$ENVIRONMENT" | jq -r '.auth');
    CLUSTER_NAME=$(echo "$ENVIRONMENT" | jq -r '.clustername');
    ZONE_NAME=$(echo "$ENVIRONMENT" | jq -r '.zone');
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

function enable-kubectl {

    # Grab cluster credentials to enable kubectl
    echo "** Enable kubectl to work with cluster **"
    gcloud container clusters get-credentials \
    $CLUSTER_NAME \
    --zone $ZONE_NAME \
    --project $PROJECT_NAME
}

environment-variables
login
set-project
enable-kubectl
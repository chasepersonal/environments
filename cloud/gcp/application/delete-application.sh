#!/bin/bash

###########################################################
#
# Program name: delete-application.sh
#
# Author: Chase Weyer
#
# This script is used to automatically delete an application
# that has been deployed on a Kubernetes network.
#
############################################################

# Get environment variables
function environment-variables {
    APPLICATION=$(cat ../gcp.json | jq .'application');
    AUTH=$(echo "$APPLICATION" | jq -r '.auth');
    DEPLOY=$(echo "$APPLICATION" | jq -r '.deployment' );
    ING=$(echo "$APPLICATION" | jq -r '.ingress' );
    SVC=$(echo "$APPLICATION" | jq -r '.deployment' );
    ENVIRONMENT=$(cat ../gcp.json | jq .'environment');
    PROJECT_NAME=$(echo "$ENVIRONMENT" | jq -r '.projectname');
    CLUSTER_NAME=$(echo "$ENVIRONMENT" | jq -r '.clustername');
    ZONE_NAME=$(echo "$ENVIRONMENT" | jq -r '.zone');
}
# Login with app deployer service account
function login {
    gcloud auth activate-service-account --key-file=$AUTH
}

function enable-kubectl {

    # Grab cluster credentials to enable kubectl
    echo "** Enable kubectl to work with cluster **"
    gcloud container clusters get-credentials \
    $CLUSTER_NAME \
    --zone $ZONE_NAME \
    --project $PROJECT_NAME
}

# Delete application based on value passed in
function delete {

    echo "** Deleteing application **"
    kubectl delete ing $ING
    kubectl delete svc $SVC
    kubectl delete deploy $DEPLOY
}

# Exit program if any of the steps fail
set -e

# Enable steps in this order:
# Set up Environment Variables
# Login
# Deploy application

environment-variables
login
enable-kubectl
delete
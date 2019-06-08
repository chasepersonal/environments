#!/bin/bash

###########################################################
#
# Program name: build-env.sh
#
# Author: Chase Weyer
#
# This script is used to automatically deploy a Kubernetes
# environment on the Google Kubernetes Engine (GKE). It will 
# take in a .json configuration file for what GKE needs in
# order to build out the environment. There will also be
# Helm installments for Ingress and Certificate manager so 
# that the platform will automatically be ready for
# application deployments that will route to an https site
#
############################################################

# Set Environment Variables
function environment-variables {
    echo "** Parsing environment variables from json file **";
    ENVIRONMENT=$(cat ../gcp.json | jq '.environment');
    DOCKER_USER=$(cat ../../shared/authorization/docker-login.json | jq -r '.username');
    DOCKER_PASS=$(cat ../../shared/authorization/docker-login.json | jq -r '.password');
    DOCKER_EMAIL=$(cat ../../shared/authorization/docker-login.json | jq -r '.email');
    DOCKER_REPO=$(cat ../../shared/authorization/docker-login.json | jq -r '.repo');
    SECRET_NAME=$(cat ../gcp.json | jq -r '.application.secretname');
    PROJECT_NAME=$(echo "$ENVIRONMENT" | jq -r '.projectname');
    CLUSTER_NAME=$(echo "$ENVIRONMENT" | jq -r '.clustername');
    ZONE_NAME=$(echo "$ENVIRONMENT" | jq -r '.zone');
    REGION=$(echo "$ENVIRONMENT" | jq -r '.region');
    IP=$(echo "$ENVIRONMENT" | jq -r '.ip');
    MACHINE_TYPE=$(echo "$ENVIRONMENT" | jq -r '.machinetype');
    IMAGE_TYPE=$(echo "$ENVIRONMENT" | jq -r '.imagetype');
    DISK_SIZE=$(echo "$ENVIRONMENT" | jq -r '.disksize');
    NUM_NODE=$(echo "$ENVIRONMENT" | jq -r '.numnode');
    NETWORK_NAME=$(echo "$ENVIRONMENT" | jq -r '.network');
    NETWORK_RANGE=$(echo "$ENVIRONMENT" | jq -r '.networkrange');
    POD_NAME=$(echo "$ENVIRONMENT" | jq -r '.pods');
    SERVICE_NAME=$(echo "$ENVIRONMENT" | jq -r '.services');
    MIN_NODES=$(echo "$ENVIRONMENT" | jq -r '.minimumnodes');
    MAX_NODES=$(echo "$ENVIRONMENT" | jq -r '.maximumnodes');
    AUTH=$(echo "$ENVIRONMENT" | jq -r '.auth');
    SUBNET_NAME=$(echo "$ENVIRONMENT" | jq -r '.subnet');
    POD_SUBNET=$(echo "$ENVIRONMENT" | jq -r '.podsubnet');
    SERVICE_SUBNET=$(echo "$ENVIRONMENT" | jq -r '.servicesubnet');
    CIDR="$IP/32";
}

function login {
    echo "** Logging into the GCP Platform **"
    gcloud auth activate-service-account --key-file=$AUTH
}

# Set project
function set-project {
    echo "** Setting project and compute zone **"
    gcloud config set project $PROJECT_NAME --quiet
    gcloud config set compute/zone $ZONE_NAME --quiet
}

function create-network {
    # Create overall network
    echo "** Creating VPC Network **"
    gcloud compute --project=$PROJECT_NAME networks create $NETWORK_NAME --subnet-mode=custom

    # Create subnet
    echo "** Creating subnet for pods and services **"
    gcloud compute --project=$PROJECT_NAME networks subnets create $SUBNET_NAME \
    --network=$NETWORK_NAME \
    --region=$REGION \
    --range=$NETWORK_RANGE \
    --secondary-range=$POD_NAME=$POD_SUBNET,$SERVICE_NAME=$SERVICE_SUBNET
}

# Create Kubernetes Cluster
function create-cluster {
    echo "** Creating cluster **"
    gcloud container clusters create "$CLUSTER_NAME" \
        --project "$PROJECT_NAME" \
        --zone "$ZONE_NAME" \
        --no-enable-basic-auth \
        --cluster-version "$CLUSTER_VERSION" \
        --machine-type "$MACHINE_TYPE" \
        --image-type "$IMAGE_TYPE" \
        --disk-size "$DISK_SIZE" \
        --scopes "https://www.googleapis.com/auth/cloud-platform" \
        --num-nodes "$NUM_NODE" \
        --network "$NETWORK_NAME" \
        --enable-cloud-logging \
        --enable-cloud-monitoring \
        --subnetwork "$SUBNET_NAME" \
        --enable-ip-alias \
        --cluster-secondary-range-name=$POD_NAME \
        --services-secondary-range-name=$SERVICE_NAME\
        --enable-autoscaling \
        --min-nodes "$MIN_NODES" \
        --max-nodes "$MAX_NODES" \
        --enable-network-policy \
        --enable-master-authorized-networks \
        --master-authorized-networks "$CIDR" \
        --enable-autoupgrade \
        --enable-autorepair \
        --maintenance-window "08:00" \
        --addons HttpLoadBalancing \
        --addons HorizontalPodAutoscaling \
        --no-issue-client-certificate \
        --metadata disable-legacy-endpoints=true
}

# Configure cli to talk to the cluster
function configure-kubectl {
    # Remove previous cluster credentials
    echo "** Removing older kubectl credentials **"
    rm -rf ~/.kube

    echo "** Configuring kubectl to point to new cluster **"
    gcloud container clusters get-credentials \
    $CLUSTER_NAME \
    --zone $ZONE_NAME \
    --project $PROJECT_NAME
}

function install-helm {
    
    # Download helm script and install it
    echo "** Installing Helm **"
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

    # Create service account and rbac role for tiller
    echo "** Creating Service Account for Tiller **"
    kubectl apply -f ../../shared/kubernetes/environment/tiller-rbac.yaml

    # Install helm to the cluster
    # Will use kube config to install into the cluster and assign service account
    echo "** Installing Tiller and Initialize Helm for the cluster"
    helm init --service-account tiller --upgrade

}

function create-static-ip {
    # Create the static ip
    echo "** Creating Static IP **"
    gcloud compute addresses create $SUBNET_NAME --project=$PROJECT_NAME --region=$REGION

    # Retrieve static ip so it can be exported
    echo "** Exporting Static IP so it can be used for Ingress install **"
    STATIC_IP=$(gcloud compute addresses describe $SUBNET_NAME --region=$REGION | awk 'FNR==1{print $2}')
}

# Install Cerfificate Manager
function install-cm {

    # Get newer manifests for cert-manager
    # This will ensure that "ClusterIssuer" is granted to the Cert Manager API
    echo "** Downloading most recent manifests for cert-manager"
    kubectl apply \
        -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml

    # Wait 60 seconds so Tiller can become ready
    echo "** Waiting 60 seconds so Tiller pod can become ready"
    sleep 60

    # Install cert-manager
    echo "** Installing cert-manager **"
    helm install --name cm \
    --namespace kube-system \
    --set createCustomResource=false \
    --set ingressShim.defaultIssuerName=letsencrypt-prod \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    --version v0.5.2 \
    stable/cert-manager

    # Apply cluster issuer credentials
    echo "** Apply credentials so that certs can be issued **"
    kubectl apply -f ../../shared/kubernetes/environment/cluster-issuer.yaml
}

function install-ingress {
    echo "** Installing Ingress **"
    helm install --name ng stable/nginx-ingress \
    --set rbac.create=true \
    --set controller.image.repository="quay.io/kubernetes-ingress-controller/nginx-ingress-controller" \
    --set controller.service.loadBalancerIP="$STATIC_IP" \
    --set controller.image.tag="0.24.1"
}

function create-secret {
    echo "** Creating Private Docker Repo secret **"
    kubectl create secret docker-registry $SECRET_NAME \
    --docker-server=$DOCKER_REPO \
    --docker-username=$DOCKER_USER \
    --docker-password=$DOCKER_PASS \
    --docker-email=$DOCKER_EMAIL
}

# Exit when any command failes
set -e

# Import variables, set the project, and create the cluster
environment-variables
login
set-project
create-network
create-cluster

# Configure kubectl
configure-kubectl

# Install helm
install-helm

# Create a static ip for ingress
create-static-ip

# Install certificate manager
install-cm

# Create static ip and install ingress
install-ingress

# Create a secret to pull from private repo
create-secret


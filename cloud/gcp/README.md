# GCP

This folder will contain scripts that allow for the automatic deployment and destruction of a Google Kubernetes Engine (GKE) cluster as applications on that cluster.

All scripts are designed to be run as follows:

`source <name of script>`

## Application
This will contain a script called `deploy-application.sh` which will automatically deploy an application on a Google Kubernetes Engine (GKE) cluster depending on the value in the `gcp.json` main configuration file.

This will also log into a private docker registry if the application is in a private repository.

## Cluster

This will contain the following scripts:

`build-env.sh` -> for building a cluster

`delete-env.sh` -> for deleting a cluster
#!/bin/bash

# Get user name of AWS from instance id
# Instance id will be passed in from terminal
# Exit if the aws command fails

set -e

FLAVOR=$(aws ec2 describe-images --image-ids $(aws ec2 describe-instances --instance-ids $1 --query 'Reservations[0].Instances[0].ImageId' --output text) --query 'Images[0].Name' --output text | cut -d "/" -f 1)

if [[ $FLAVOR == centos ]];
then
    USER="centos"
elif [[ $FLAVOR == debian ]];
then
    USER="debian"
elif [[ $FLAVOR == ubuntu ]];
then
    USER="ubuntu"
else
    USER="ec2-user"
fi

# Print out user to stdout
echo "$USER"

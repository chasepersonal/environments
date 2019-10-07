#!/bin/bash

# Retrieve Instance ID from CLI
# Run AWS command against jq to get public dns

PUBLIC_DNS="$(aws ec2 describe-instances --instance-ids $1 | jq -r '.Reservations[0].Instances[0].PublicDnsName')"


if [[ -z $PUBLIC_DNS ]] || [[ $PUBLIC_DNS == "null" ]];
then
    echo "Could not retrieve Public DNS information"
    echo "This might mean the machine doesn't exist"
    echo "Check your AWS account and try again"
    exit 1
else
    echo "$PUBLIC_DNS"
fi
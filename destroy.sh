
# !/bin/bash


export ENV_ID=$(confluent environment list -o json | jq -r '.[] | select(.name=="onchainsentinel") | .id')

# Deleting environment, deletes all resources
confluent environment delete $ENV_ID




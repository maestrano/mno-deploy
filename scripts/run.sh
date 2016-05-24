#!/bin/bash

#==============================================================
# This scripts creates the Maestrano infrastructure on AWS
#==============================================================

# Move to ansible directory
cd ansible

export ANSIBLE_HOST_KEY_CHECKING=false

# AWS Keys used to setup the actual AWS infrastructure
# These keys are local and will not be written to any other location (such as AWS user-data)
: ${AWS_ACCESS_KEY_ID?"Need to set variable: AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY?"Need to set variable: AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION?"Need to set variable: AWS_DEFAULT_REGION"}
export AWS_REGION=$AWS_DEFAULT_REGION

# Ansible configuration files
: ${ENVIRONMENT_CONFIGURATION?"Need to set variable: ENVIRONMENT_CONFIGURATION"}

# Execute playbooks to setup environment
ansible-playbook -vvvv -i hosts site.yml --extra-vars="{\"env_config\": \"${ENVIRONMENT_CONFIGURATION}\"}" --vault-password-file ${ANSIBLE_VAULT_PASSWORD_FILE}

#!/bin/bash

#==============================================================
# Generate an inventory file from the AWS account
# This inventory file is used by the specs to test the
# servers
#==============================================================

#====================================================
# 1 - Prepare environment variables
#====================================================
# Navigate to CI folder
cd tmpdeploy/aws-ubuntu-ci

# Create inventory folder (inventory and access keys)
mkdir -p inventory

#====================================================
# 2 - Download Infra ssh key
#====================================================
cd ./inventory

bucket_location="mno-deploy-ci/aws-ubuntu-config"
aws s3 cp s3://$bucket_location/key-ssh.pem ../inventory/key-ssh.pem > /dev/null
chmod 600 ../inventory/key-ssh.pem

cd ..

#====================================================
# 3 - Prepare environment variables
#====================================================
# Set ansible vars to use in run.sh script
export ENVIRONMENT_CONFIGURATION="aws_ubuntu_ci"
export ANSIBLE_VAULT_PASSWORD_FILE="./key.txt"

# setup AWS keys used for actual infrastructure setup
ORIG_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ORIG_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ORIG_AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_ACCESS_KEY_ID=$TST_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$TST_AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$TST_AWS_DEFAULT_REGION

#====================================================
# 4 - Collect inventory
#====================================================
cd ./ansible

ansible-playbook -vvvv -i hosts inventory.yml --extra-vars="{\"env_config\": \"${ENVIRONMENT_CONFIGURATION}\"}" --vault-password-file ${ANSIBLE_VAULT_PASSWORD_FILE}
retval=$?

#====================================================
# 5 - Cleanup
#====================================================
# Re-instate variables
export AWS_ACCESS_KEY_ID=$ORIG_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ORIG_AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$ORIG_AWS_DEFAULT_REGION
unset ENVIRONMENT_CONFIGURATION
unset ANSIBLE_VAULT_PASSWORD_FILE

# Cleanup
cd ../..

# Exit with ansible return code
exit $retval

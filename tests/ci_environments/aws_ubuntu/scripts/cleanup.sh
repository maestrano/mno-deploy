#!/bin/bash

#==============================================================
# Cleanup the AWS account
# This script assumes that 'setup_infrastructure.sh' has been
# run previously
#==============================================================

#====================================================
# 1 - Prepare environment variables
#====================================================
# Navigate to ansible folder
cd tmpdeploy/aws-ubuntu-ci/ansible

#====================================================
# 2 - Prepare environment variables
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

ansible-playbook -vvvv -i hosts cleanup.yml --extra-vars="{\"env_config\": \"${ENVIRONMENT_CONFIGURATION}\"}" --vault-password-file ${ANSIBLE_VAULT_PASSWORD_FILE}
retval=$?

#====================================================
# 4 - Cleanup
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

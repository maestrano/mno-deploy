#!/bin/bash

#==============================================================
# AWS Infrastructure setup
# Launch the ansible scripts with local configuration
# and execute AWS infrastructure setup script
#==============================================================

#====================================================
# 1 - Prepare deployment package
#====================================================
# Setup temporary ansible directory
mkdir tmpdeploy
rm -rf tmpdeploy/aws-ubuntu-ci
mkdir tmpdeploy/aws-ubuntu-ci

# Copy core deployment scripts
cp -R ../ansible tmpdeploy/aws-ubuntu-ci/
cp -R ../scripts tmpdeploy/aws-ubuntu-ci/

# Apply environment specific configuration
cp -R ci_environments/aws_ubuntu/ansible/* tmpdeploy/aws-ubuntu-ci/ansible/
cp -R ci_environments/aws_ubuntu/scripts/* tmpdeploy/aws-ubuntu-ci/scripts/

# Navigate to directory
cd tmpdeploy/aws-ubuntu-ci

#====================================================
# 2 - Download vault key
#====================================================
bucket_location="mno-deploy-ci/aws-ubuntu-config"
aws s3 cp s3://$bucket_location/key.txt ./ansible/key.txt > /dev/null

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
# 4 - Execute infrastructure setup script
#====================================================
sh scripts/run.sh
retval=$?

#====================================================
# 5 - Cleanup
#====================================================
# Clean up
cd ..

# Re-instate variables
export AWS_ACCESS_KEY_ID=$ORIG_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ORIG_AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$ORIG_AWS_DEFAULT_REGION
unset ENVIRONMENT_CONFIGURATION
unset ANSIBLE_VAULT_PASSWORD_FILE

# Exit with ansible return code
exit $retval

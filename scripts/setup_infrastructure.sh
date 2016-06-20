#!/bin/bash

#==============================================================
# AWS Infrastructure setup
# Launch the ansible scripts with local configuration
# - Download specified mno-deploy package version
# - Merge with specific configuration
# - Execute AWS infrastructure setup script
#==============================================================

# Export variables
# export MNO_DEPLOY_VERSION=develop/latest
# export ENVIRONMENT_CONFIGURATION=
# export ANSIBLE_VAULT_PASSWORD_FILE=
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_DEFAULT_REGION=

# mno-deploy package version
: ${MNO_DEPLOY_VERSION?"Need to set variable: MNO_DEPLOY_VERSION"}

# Go to current script directory
cd "$(dirname "$0")/.."
current_path=`pwd`

#====================================================
# 1 - Download specified mno-deploy package version
#====================================================
# Clean up mno-infrastructure directory
rm -rf mno-infrastructure
mkdir mno-infrastructure
cd mno-infrastructure

if [ "$MNO_DEPLOY_VERSION" = "local" ]; then
  # Local testing, copy relative files
  cd "$(dirname "$0")/../../.."
  cp -R ./mno-deploy/* mno-deploy-maestrano/mno-infrastructure/
  cd mno-deploy-maestrano/mno-infrastructure
else
  # Download the specified version of the deployment scripts
  curl -s -o ./mno-infrastructure.tar.gz https://s3-ap-southeast-1.amazonaws.com/mnoe-packages/mno-infrastructure/${MNO_DEPLOY_VERSION}.tar.gz

  # Extract the package and run install script
  tar -xzf mno-infrastructure.tar.gz
fi

#====================================================
# 2 - Merge with local configuration
#====================================================
cp -R ../ansible/* ./ansible/
cp -R ../scripts/* ./scripts/

#====================================================
# 3 - Execute infrastructure setup script
#====================================================
cd ${current_path}/mno-infrastructure
sh scripts/run.sh "$@"

# Clean up
cd ${current_path}
rm -rf mno-infrastructure

#!/bin/bash

#==============================================================
# Instance setup (run on the local server from user data)
# Launch the ansible scripts with local configuration
# - Download specified mno-deploy package version
# - Merge with local configuration
# - Execute instance setup script
#==============================================================

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

# Use latest version of the deployment scripts
mno_deploy_version="ci-staging/latest"

# Download the specified version of the deployment scripts
curl -s -o ./mno-infrastructure.tar.gz https://s3-ap-southeast-1.amazonaws.com/mnoe-packages/mno-infrastructure/${mno_deploy_version}.tar.gz

# Extract the package and run install script
tar -xzf mno-infrastructure.tar.gz

#====================================================
# 2 - Merge with local configuration
#====================================================
cp -R ../ansible/* ./ansible/
cp -R ../scripts/* ./scripts/
chmod 755 ./scripts/*

#====================================================
# 3 - Execute instance setup script
#====================================================
cd "${current_path}/mno-infrastructure"
sh scripts/install.sh $1 $2

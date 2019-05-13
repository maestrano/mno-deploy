#!/bin/bash

#==============================================================
# Default user_data for an instance (Ansible template)
#
# Runs the following sequence:
# - Setup proxy configuration
# - Linux packages update
# - Download latest deployment scripts configuration (these scripts)
# - Run installation script (setup_instance.sh)
#==============================================================

# Ansible variables required
# - tenant_dropbox_s3_aws_access_key
# - tenant_dropbox_s3_aws_secret_key
# - tenant_dropbox_s3_aws_region
# - mno_deploy_configuration_bucket
# - mno_deploy_configuration_path

#====================================================
# 1 - Create redeploy script
#====================================================
if [ ! -f "/opt/maestrano/redeploy.sh" ]; then
  mkdir -p /opt/maestrano
  script=$(readlink -f $0) # path to self
  echo "bash $script $1 $2 $3 $4 $5" > /opt/maestrano/redeploy.sh
  chmod 775 /opt/maestrano/redeploy.sh
fi

#====================================================
# 2 - Linux packages update
#====================================================
# Ubuntu: Install Dependencies
if [ "$(which apt-get > /dev/null 2>&1)$?" == "0" ]; then
  apt-get -y update && apt-get install -y python-pip
fi

# RHEL: Install depdendencies
if [ "$(which yum > /dev/null 2>&1)$?" == "0" ]; then
  # Enable EPEL
  rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
  yum -y update && yum install -y python-pip
fi

# Install AWS CLI using pip
pip install awscli

#=====================================================
# 3 - Download latest deployment scripts configuration
#=====================================================
# Keys used to retrieve the mno-deploy-configuration package
export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export AWS_DEFAULT_REGION=ap-southeast-1

# S3 bucket of the deployment configuration scripts
export MNO_DEPLOY_BUCKET=$3
export MNO_DEPLOY_PATH=/$4

# Directory clean up
rm -rf /opt/mno-deploy-configuration
mkdir -p /opt/mno-deploy-configuration
cd /opt/mno-deploy-configuration

# Download the latest version of the scripts
KEY=`aws s3 ls s3://${MNO_DEPLOY_BUCKET}${MNO_DEPLOY_PATH}/ --recursive | sort | tail -n 1 | awk '{print $4}'`
aws configure set s3.signature_version s3v4 # Enable AWS Signature Version 4
aws s3 cp s3://${MNO_DEPLOY_BUCKET}/$KEY ./mno-deploy-configuration.tar.gz

#====================================================
# 4 - Run installation script
#====================================================
# Extract the package and run install script
tar -xzf mno-deploy-configuration.tar.gz
sh scripts/setup_instance.sh nex-app-server-local $5

# Avoid failure on install - continue provisioning flow
exit 0

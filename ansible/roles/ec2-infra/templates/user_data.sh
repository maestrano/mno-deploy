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
# 1 - Setup proxy configuration
#====================================================
{% if proxy_host is defined and proxy_port is defined %}
# Proxy setup
export http_proxy=http://{{ proxy_host }}:{{ proxy_port }}
export https_proxy=http://{{ proxy_host }}:{{ proxy_port }}
{% if proxy_ignore is defined %}
export no_proxy={{ proxy_ignore }}
{% else %}
export no_proxy="localhost,169.254.169.254"
{% endif %}
{% endif %}

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
export AWS_ACCESS_KEY_ID={{ tenant_dropbox_s3_aws_access_key }}
export AWS_SECRET_ACCESS_KEY={{ tenant_dropbox_s3_aws_secret_key }}
export AWS_DEFAULT_REGION={{ tenant_dropbox_s3_aws_region }}

# MongoDB specific configuration
{% if mongodb_master is defined %}
export MONGODB_MASTER={{ mongodb_master }}
{% endif %}
{% if mongodb_bind_ip is defined %}
export MONGODB_BIND_IP={{ mongodb_bind_ip }}
{% endif %}

# S3 bucket of the deployment configuration scripts
export MNO_DEPLOY_BUCKET={{ mno_deploy_configuration_bucket }}
export MNO_DEPLOY_PATH={{ mno_deploy_configuration_path }}

# Directory clean up
rm -rf /opt/mno-deploy-configuration
mkdir -p /opt/mno-deploy-configuration
cd /opt/mno-deploy-configuration

# Download the latest version of the scripts
KEY=`aws s3 ls s3://${MNO_DEPLOY_BUCKET}${MNO_DEPLOY_PATH}/ --recursive | sort | tail -n 1 | awk '{print $4}'`
aws s3 cp s3://${MNO_DEPLOY_BUCKET}/$KEY ./mno-deploy-configuration.tar.gz

#====================================================
# 4 - Run installation script
#====================================================
# Extract the package and run install script
tar -xzf mno-deploy-configuration.tar.gz
sh scripts/setup_instance.sh {{ maestrano_component }} {{ env_config }} "$@"

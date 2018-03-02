#!/bin/bash

#==============================================================
# Setup of a Maestrano component instance
# Performs an installation of the required packages and calls the ansible scripts
#
# Supports Debian and CentOS distributions
# Usage: sh install.sh [maestrano_component] [env_config]
# eg: sh install.sh connec-app-server-ec2 uat
#==============================================================

# Maestrano component and configuration to install
maestrano_component=$1
env_config=$2
current_path=`pwd`

ansible_command="ansible-playbook -vvv -i hosts ${maestrano_component}.yml --extra-vars='{\"env_config\": \"${env_config}\"}' --vault-password-file ${current_path}/scripts/vault_pass.sh"

echo "Running script with maestrano_component ${maestrano_component} and env_config ${env_config}"

rm -rf /etc/ansible
cp -R ./ansible /etc/

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

do_install() {
  set -x
  apt-get -y update
  # apt-get -y upgrade
  # Force upgrade in non-interactive mode, grub-pc package may cause prompt to appear
  DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade 
  apt-get -y install build-essential
  apt-get -q -y --no-install-recommends install unattended-upgrades git python-yaml libyaml-dev python-jinja2 python-httplib2 python-keyczar python-dev libffi-dev libssl-dev python-pip
  pip install --upgrade setuptools
  pip install -Iv ansible==2.4.3.0
  pip install boto boto3 botocore pycrypto

  # Run Ansible
  cd /etc/ansible
  eval $ansible_command
  return 0
}

# Run installation function
do_install
RETVAL=$?
exit $RETVAL

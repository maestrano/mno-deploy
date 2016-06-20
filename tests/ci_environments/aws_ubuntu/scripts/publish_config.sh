#!/bin/bash

#==============================================================
# This scripts publishes the CI configuration scripts to
# the CI Configuration S3 bucket
#==============================================================

# AWS keys used to publish the package on S3
: ${AWS_ACCESS_KEY_ID?"Need to set variable: AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY?"Need to set variable: AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION?"Need to set variable: AWS_DEFAULT_REGION"}

# S3 bucket and path
bucket_location=mno-deploy-ci/aws-ubuntu-config

# Download AWS CLI
pip install awscli

# Prepare package
cd ci_environments/aws_ubuntu
tar -czf aws-ubuntu-config.tar.gz *

# Upload package to S3 CI bucket
aws s3 cp aws-ubuntu-config.tar.gz s3://$bucket_location/latest.tar.gz

# Cleanup
rm -f aws-ubuntu-config.tar.gz
cd ../..

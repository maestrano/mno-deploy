#!/bin/bash

#==============================================================
# This scripts publishes the deployment scripts to an S3 bucket
# To be executed by a CI tool (CodeShip)
#==============================================================

# AWS keys used to publish the package on S3
: ${AWS_ACCESS_KEY_ID?"Need to set variable: AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY?"Need to set variable: AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION?"Need to set variable: AWS_DEFAULT_REGION"}

# CI build number
: ${CI_BUILD_NUMBER?"Need to set variable: CI_BUILD_NUMBER"}

# S3 bucket and path
bucket_location=pwc-next-uat-mnoe-dropbox/mno-infrastructure/${CI_BRANCH}

# Download AWS CLI
pip install awscli

# Prepare package
mkdir -p tmp-pkg
cp -rp ansible tmp-pkg/
cp -rp scripts tmp-pkg/
cd tmp-pkg
tar -czf package.tar.gz *

# Upload package to S3
aws s3 cp package.tar.gz s3://$bucket_location/$CI_BUILD_NUMBER.tar.gz --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp package.tar.gz s3://$bucket_location/latest.tar.gz --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

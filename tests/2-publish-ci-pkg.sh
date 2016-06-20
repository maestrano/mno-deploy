#!/bin/bash

#==============================================================
# This scripts publishes the core deployment scripts to the
# CI S3 bucket
#==============================================================

# AWS keys used to publish the package on S3
: ${AWS_ACCESS_KEY_ID?"Need to set variable: AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY?"Need to set variable: AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION?"Need to set variable: AWS_DEFAULT_REGION"}

# S3 bucket and path
bucket_location=mnoe-packages/mno-infrastructure/ci-staging

# Download AWS CLI
pip install awscli

# Prepare package
mkdir -p tmp-pkg-ci
cp -rp ../ansible tmp-pkg-ci/
cp -rp ../scripts tmp-pkg-ci/
cd tmp-pkg-ci
tar -czf tmp-pkg-ci-pkg.tar.gz *

# Upload package to S3 CI bucket
aws s3 cp tmp-pkg-ci-pkg.tar.gz s3://$bucket_location/latest.tar.gz --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

# Cleanup
cd ..
rm -rf tmp-pkg-ci

#!/bin/bash

#==============================================================
# This scripts publishes the CI configuration scripts to
# the CI Configuration S3 bucket
#==============================================================

# Publish the AWS Ubuntu CI config
sh ci_environments/aws_ubuntu/scripts/publish_config.sh

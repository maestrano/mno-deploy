#!/bin/bash

#==============================================================
# This script destroys all the test resources created during
# the CI process
#==============================================================

#==============================================================
# Destroy each test environment
#==============================================================
# Destroy the AWS Ubuntu Test environment
sh ci_environments/aws_ubuntu/scripts/cleanup.sh
retval=$?

#==============================================================
# Final cleanup
#==============================================================
# Remove the tmpdeploy folder
rm -rf tmpdeploy

exit $retval

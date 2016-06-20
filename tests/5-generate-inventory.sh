#!/bin/bash

#==============================================================
# This script generates the inventory for each CI environment
#==============================================================

# Deploy the AWS Ubuntu Test environment
sh ci_environments/aws_ubuntu/scripts/inventory.sh

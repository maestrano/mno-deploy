#!/bin/bash

#==============================================================
# This script runs ansible for each test environment and prepare
# live PaaS environments
#==============================================================

# Deploy the AWS Ubuntu Test environment
sh ci_environments/aws_ubuntu/scripts/setup_infrastructure.sh
retval=$?

if [ $retval -eq 0 ]; then
  # Set wait time (use existing TST_INFRA_WAIT or fallback on default)
  TST_INFRA_WAIT=${TST_INFRA_WAIT-10} # set wait time (minutes)
  let "wait_time=$TST_INFRA_WAIT*60" # set wait time (seconds)

  # Give some time to the infrastructure to prepare
  echo "[RUN] sleep for $TST_INFRA_WAIT minutes while infrastructure is provisioning"
  sleep $wait_time
fi

exit $retval

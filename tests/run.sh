#!/bin/bash
APP_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

# Install Ansible
echo "[RUN] Installing ansible, boto and pycrypto ..."
pip install -Iv ansible==2.0.2.0 > /dev/null
pip install boto pycrypto > /dev/null

# Move to test directory
cd $APP_ROOT/tests

#--------------------------------------------------------
# 1. Check syntax of ansible scripts
#--------------------------------------------------------
echo "[RUN] Checking Ansible syntax..."
bash 1-check-syntax.sh
syntax_check_retval=$?

if [ $syntax_check_retval -eq 0 ]; then
  echo "[SUCCESS] Ansible syntax is correct"
else
  echo "[ERROR] Ansible syntax incorrect"
  exit 1
fi

# Stop here if end-to-end testing is not enabled or if not on the
# tested branch (should be master)
if [ "$TST_ENABLED" != "true" ] || [ "$CI_BRANCH" != "$TST_BRANCH" ];  then
  echo "[SKIP] Skipping end-to-end tests (env var TST_ENABLED set to false or we are not currently on the TST_BRANCH)"
  exit 0
fi

#--------------------------------------------------------
# 2. Publish Core deployment scripts to a CI bucket
#--------------------------------------------------------
echo "[RUN] Publishing core deployment scripts onto staging..."
bash 2-publish-ci-pkg.sh

if [ $? -eq 0 ]; then
  echo "[SUCCESS] Core deployment scripts have been published to CI bucket"
else
  echo "[ERROR] Unable to publish core deployment scripts to CI bucket"
  exit 1
fi

#--------------------------------------------------------
# 3. Publish test environment configuration to a CI bucket
#--------------------------------------------------------
echo "[RUN] Publishing CI deployment configuration onto staging..."
bash 3-publish-ci-config.sh

if [ $? -eq 0 ]; then
  echo "[SUCCESS] Configuration scripts have been published to CI bucket"
else
  echo "[ERROR] Unable to publish configuration scripts to CI bucket"
  exit 1
fi

#--------------------------------------------------------
# 4. Setup test environments
#--------------------------------------------------------
echo "[RUN] Setting up test environments..."
bash 4-setup-ci-infra.sh
infra_setup_retval=$?

if [ $infra_setup_retval -eq 0 ]; then
  echo "[SUCCESS] Test environment(s) have been successfully setup"
else
  echo "[ERROR] Unable to properly setup test environment(s)"
fi

#--------------------------------------------------------
# 5. Generate inventory
#--------------------------------------------------------
inventory_retval=0

if [ $infra_setup_retval -eq 0 ]; then
  echo "[RUN] Generating infrastructure inventory..."
  bash 5-generate-inventory.sh
  inventory_retval=$?
else
  echo "[SKIP] Skipping inventory as there were issues deploying infrastructure components"
fi

#--------------------------------------------------------
# 6. Run test suite
#--------------------------------------------------------
test_suite_retval=0

if [ $infra_setup_retval -eq 0 ] && [ $inventory_retval -eq 0 ]; then
  echo "[RUN] Running end-to-end test suite..."
  bash 6-run-test-suite.sh
  test_suite_retval=$?
else
  echo "[SKIP] Skipping test suite there were issues deploying infrastructure components"
fi

#--------------------------------------------------------
# 7. Cleanup test resources
#--------------------------------------------------------
echo "[RUN] Cleaning up all test infrastructure resources..."
bash 7-cleanup.sh
infra_cleanup_retval=$?

if [ $infra_cleanup_retval -eq 0 ]; then
  echo "[SUCCESS] Cleanup successful"
else
  echo "[ERROR] Issues cleaning up infrastructure resources. Please investigate manually."
fi

#--------------------------------------------------------
# Summary and exit
#--------------------------------------------------------
# Go back to top directory
cd $APP_ROOT

# Exit with
echo "Summary:"
echo "----------"
echo "Syntax check:  $syntax_check_retval"
echo "Infra setup:   $infra_setup_retval"
echo "Inventory:   $infra_setup_retval"
echo "E2E Tests:     $test_suite_retval"
echo "Infra cleanup: $infra_setup_retval"

# Final return code
let "retval = $infra_setup_retval + $inventory_retval + $test_suite_retval + $infra_cleanup_retval"
exit $retval

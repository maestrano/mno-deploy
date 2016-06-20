#!/bin/bash

#==============================================================
# This script runs the test suite on the infrastructure(s)
#==============================================================
cd serverspecs

# Install dependencies
bundle install

# Run the test suite
bundle exec rake spec

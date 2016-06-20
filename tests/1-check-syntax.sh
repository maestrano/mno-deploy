#!/bin/bash
APP_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

# Check syntax on all playbooks
find $APP_ROOT/ansible -maxdepth 1 -name '*.yml' | xargs -n1  ansible-playbook --syntax-check --list-tasks -i $APP_ROOT/ansible/hosts

# Maestrano Infrastructure

The complete Maestrano infrastructure can be deployed on demand on AWS using these scripts
The `ansible` directory contains the Ansible playbooks to create a new environment and setup the components

## Infrastructure configuration and setup
The Maestrano infrastructure is setup on AWS inside a VPC
It contains an ASG for every component of the platform (frontend, mnohub, nex!, connec!, impac!)

### Setup a new environment
Create a directory structure as follows. Copy the scripts files `setup_infrastructure.sh`, `setup_instance.sh` and `vault_pass.sh` under the directory `myproject/scripts`.
```
+-- _myproject
|   +-- _ansible
|       +-- _files
|           +-- _public_keys
|           +-- _xero_certs
|       +-- _vars
|           +-- myenv.yml
|           +-- myenv_secret.yml
|   +-- scripts
|       +-- setup_infrastructure.sh
|       +-- setup_instance.sh
|       +-- vault_pass.sh
```

### Ansible variable and secrets
The infrastructure needs to be configured
- Create a yaml configuration file under `ansible/vars` (eg: `ansible/vars/myenv.yml`) and customise values from `ansible/group_vars/all` as needed
- Create a yaml secret file file under `ansible/vars` (eg: `ansible/vars/myenv_secret.yml`) containing passwords and secrets
- Encrypt the secret file with ansible vault: `ansible-vault encrypt ansible/vars/myenv_secret.yml`
- Store the ansible vault password in a text file

### Infrastructure setup
- Run the following script

```
export AWS_ACCESS_KEY_ID=<some-key>
export AWS_SECRET_ACCESS_KEY=<some-key>
export AWS_REGION=ap-southeast-2
export ANSIBLE_VAULT_PASSWORD_FILE=path/to/ansible/vault/key
export ENVIRONMENT_CONFIGURATION=myenv
export MNO_DEPLOY_VERSION=develop/latest
sh scripts/setup_infrastructure.sh
```

### Common components configuration
#### User ssh keys
To be stored under `ansible/files/public_keys`

### Mnohub configuration
#### Xero certificates
To be stored under `ansible/files/xero_certs`

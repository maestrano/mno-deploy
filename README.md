# Maestrano Infrastructure

[ ![Codeship Status for maestrano/mno-deploy](https://codeship.com/projects/f6587590-e990-0133-f67a-4afac8d396b8/status?branch=master)](https://codeship.com/projects/147638)

The complete Maestrano infrastructure can be deployed on demand on AWS using these deployment scripts. Automation is based on Ansible using a two steps process:
Creation of the infrastructure on AWS (Virtual Private Cloud, Auto Scaling Groups, Elastic Load Balancers, private DNS entries, etc…)
Automatic setup of new servers launched by the ASGs

*Tested with Ansible 2.0.2.0*

## Infrastructure configuration and setup
The default cloud provider used to deploy the Maestrano platform is Amazon Web Services running inside a VPC. The different components of the platform are deployed independently (frontend, mnohub, nex!, connec!, impac!)
[ ![Architecture diagram](https://raw.githubusercontent.com/maestrano/mno-deploy/develop/architecture_diagram.png)]

### Setup a new environment
This set of scripts is generic and needs to be configured on a per environment basis. The recommended approach is to create a new project to pull down the deployment scripts and merge them with your local configuration.

Create a directory structure as follows and copy the scripts files `setup_infrastructure.sh`, `setup_instance.sh` and `vault_pass.sh` under the directory `myproject/scripts`.
```
+-- _myproject
|   +-- _ansible
|       +-- _files
|           +-- _public_keys
|           +-- _xero_certs
|       +-- _vars
|   +-- scripts
|       +-- setup_infrastructure.sh
|       +-- setup_instance.sh
|       +-- vault_pass.sh
```

### Ansible configuration
#### Basic configuration
Copy the default configuration file from `mno-deploy/ansible/vars/example.yml` to `ansible/vars/myenv.yml` and set the values. A complete list of configuration properties is defined in the file `ansible/group_vars/all`.

An example of configuration file is available under `mno-deploy/tests/ci_environments/aws_ubuntu/ansible/vars/aws_ubuntu_ci.yml`

#### Passwords and secrets
Copy the default secrets file from `mno-deploy/ansible/vars/example_secrets.yml` to `ansible/vars/myenv_secrets.yml` and update with your passwords and secrets. This file will be encrypted using ansible vault commands:
ansible-vault encrypt `ansible/vars/myenv_secrets.yml`
Store the ansible vault password in a text file that will be reused as part of the deployment scripts to decrypt this file at runtime.

### Infrastructure setup
#### Script configuration
The provided default scripts/setup_infrastructure.sh sets up the infrastructure using the following steps

- Pull the latest version of the mno-deploy scripts from the Maestrano S3 bucket
- Merge with the local ansible configuration and scripts
- Execute the Ansible scripts to setup the AWS infrastructure

This script can be modified to suit your needs if you want to pull a specific version of the deployment scripts or use your own version.

#### Setup the infrastructure
To run the deployment scripts, you need to have Ansible installed on the machine running the setup script. It is recommended to use Ansible version 2.0.2.0.
To create a new infrastructure, you need to have an AWS account with access keys having access to EC2, S3, Route53, RDS and Elasticache.
Run the following script
```
export AWS_ACCESS_KEY_ID=<some-key>
export AWS_SECRET_ACCESS_KEY=<some-key>
export AWS_REGION=<some-region> (eg: ap-southeast-2)
export ANSIBLE_VAULT_PASSWORD_FILE=path/to/ansible/vault/key
export ENVIRONMENT_CONFIGURATION=myenv
export MNO_DEPLOY_VERSION=develop/latest
sh scripts/setup_infrastructure.sh
```

Follow the Ansible setup steps on screen and verify the AWS infrastructure has been created under the AWS console.

## Components configuration
### Common configuration
#### User ssh keys
To add SSH keys to the instances, you need to add the keys to the folder `ansible/files/public_keys` and them to the Ansible configuration:

```
# List of user SSH keys
ssh_users:
  - { name: "ubuntu", file: "files/public_keys/my-ssh-key" }
```

### Mnohub configuration
#### Xero certificates
Xero certificate files must be added to `ansible/files/xero_certs/RAILS_ENVIRONMENT/`
- privatekey.pem
- entrust-cert.pem
- entrust-private-nopass.pem

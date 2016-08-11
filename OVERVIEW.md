# Background ideas

An environment is a functioning collection of maestrano components, each component is either a jruby or mri ruby app. For PwC these are:

+ MNO HUB (aka next-access.api..) << Authentication and users etc etc in next
+ PWC Enterprise is their white labelled front end, and often referred to as 'frontend'
+ COMPOUND (aka next-compound), while frontend originally in a mno context, pulls data from impac, for PwC it pulls it from compound which pulls it from impac
+ IMPAC (aka next-reporting.api...) << Rails app takes data from conect and masages into reporting widget of pwc enterprise
+ CONNEC (aka next-exchange.api.) << gets data from xero myob etc and sucks data into mongo

An environment is defined by two main repositories, plus one for each component:

+ mno-deploy, which defines infrastructure.
+ mno-deploy-next, which specfies the variables that control the behaviour of infrastructure and values applied in the configuration

Everytime a change to either of these is made, the repository is packaged and pushed to s3 where its available as latest.tar.gz (or presumably by version nubmer - tbc). PwC have a github version of these, plus one for frontend and compound. The other components only have the s3 package available as they are proprietory.

For PWC the name of these buckets with paths, hosted in the UAT account are:
+ Infrastructure: _pwc-next-uat-mnoe-dropbox/mno-infrastucture/branch-name_ (where branch name is the gh branch being deployed
+ Configuration:  _pwc-next-uat-mnoe-dropbox/mno-deploy-next/branch-name_ 

Functionally an environment consists of two parts:
1. AWS infrastucture
1. Configuration of each of the instances so they function as maestrano components.

The 'mno-deploy', or infrastructure, covers both tese functions.

Within the infrastructure ansible, is a template called user_data.sh. Each component in the environment has an autoscaling group, and associated launch configuration. The launch configuration specifies how an instance to be used for a given component is to be launched; Which AMI, what instance type, what storage options are needed, and what 'user data' to apply. When ansible creates these it renders user data appropriate for that component, and has the settings needed to find the infrastructure and configuration packages and to use these to run ansible to setup the component in quesiton correctly on that instances (more details below). This is the 'link' between infrastructure and component. 

The script can be found on the instance at /var/lib/cloud/instance/scripts/part-001, and can be re-ran (theortectially `/usr/bin/cloud-init start` or `rm -fr /var/lib/cloud && /usr/bin/cloud-init -d init` should work too, depending on version of cloud init), and should redeploy the component when needed. It can also be pulled down from the instances meta-data and re-ran using 

```
curl -s http://169.254.169.254/latest/user-data|bash
```


## Infrastructure flow
 
This is the process of building out the AWS infrastructure, by calling either setup_infrastucture.sh if you want a copy on merge, or run.sh to setup env and run the ansible playbook site.yml, or just run ansible-playbook wiht site.yml directly. 

+ Execute: _setup_infrastructure.sh_
  + Runs On: Local machine (?), codeship, other?
  + Comment: Pulls down configs and infrastructure from s3, and merges (via copy) localwork with the intent of running the entire process of building AWS infrastructure from scratch by calling run.sh
  + Executes: _run.sh_
    + Runs on: Local machine (?), codeship, other? 
    + Comments: Runs ansible with the env_config variable picked up from ENV to setup the aws infrastucture. Relies on having variables etc fully configured either locally or as pulled down from s3.
    + Executes: Ansible playbook with _site.yml_
        + Runs on: Local machine (?), codeship, other? 
        + Executes: Ansible role called _ec2-infra  (roles/ec2-infra/tasks/main.yml)_
	  + Comments: Runs the tasks defined in ec2-infra role, depending on the skip value set in vars files.
          + Executes: Each task conditionally within the ansible role called  _ec2-infra  (roles/ec2-infra/tasks/*.yml)_

### Summary

So the main way points on the infrastructure setup path are:

```
 setup_infrastructure.sh -> run.sh -> ansible: site.yml -> ec2-infra tasks/* which create launch configs with user data from user_data.sh
```

## Component setup flow

+ Executes: User data script (automatically on instance first boot or _/var/lib/cloud/instance/scripts/part-001_
  + Comments: Defined in _ansible/rolesec2-infra/templates/user_data.sh_ and is used for initial configuration of instance which also deploys latest infrastructure, configuration and code.
  + Executes: _setup_instance.sh_ 
  + Comments: Expects to be ran from user data, pass name of thing to setup and env (uat etc). Its primary intent is to fetch and unpack the latest infrastructure code.
  + Executes: install.sh  
    + Comments: Assumes ubuntu and setups instance for ansible to run on it, then runs ansible with the component playbook that sets up and deploys that component/app. Its details are passed in from setup_instance.sh
    + Executes: _component_playbook_ (for example _ansible/mno-enterprise-server-local.yml_)
      + Comment: This runs the configurations and package installations needed, then calls the role for that component.

### Summary

So the main way points on the configuration setup path are:

```
 userdata (triggered by instance launch or by ssh doing an up date) -> setup_instance.sh -> install.sh -> ansible: component playbook -> ansible: component role
```

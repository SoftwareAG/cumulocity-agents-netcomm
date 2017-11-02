# Get started
this documentation is for installing the cumulocity software on a centos7 OS with chef12.
first you need a chef-server 12

## Install Chef-Server
- create a new ec2 server on the AWS GUI
- `ssh -i '.chef/keys/ffaerber.pem' centos@xxx.xxx.xxx.xxx`
- `sudo su`
- `yum install vim make gcc wget -y`
- `vim /etc/sysconfig/selinux` change to SELINUX=disabled
- `echo preserve_hostname: true >> /etc/cloud/cloud.cfg` ec2 Issue https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/
- `hostnamectl set-hostname ec2-52-16-90-217.eu-west-1.compute.amazonaws.com --static`
- `reboot`
- `wget https://packages.chef.io/files/stable/chef-server/12.15.6/el/7/chef-server-core-12.15.6-1.el7.x86_64.rpm`
- `rpm -ivh chef-server-core-*.rpm`
- `chef-server-ctl reconfigure`
- `chef-server-ctl install chef-manage`
- `opscode-manage-ctl reconfigure`
- `chef-server-ctl reconfigure`
- `mkdir /root/.chef/`
- `chef-server-ctl user-create cli Admin Cumulocity admin@cumulocity.com 12345678 --filename /root/.chef/cli.pem`
- `chef-server-ctl org-create myorg 'MyOrganization' /root/.chef/myorg-validator.pem`
- `chef-server-ctl org-user-add myorg cli`
- copy cli.pem and myorg-validator.pem in your chef-repo under .chef
- `knife ssl fetch ` for info to fix the ssl errors
- test the connection by running `bundle exec knife node list` No error should be seen.

## Install Chef-Server  (the way how chef12.cumulocity.com has been deployed)
- `yum install vim make gcc wget mc telnet mlocate -y`
- `vim /etc/sysconfig/selinux`
- `curl http://169.254.169.254/latest/meta-data/public-ipv4`
- `echo preserve_hostname: true >> /etc/cloud/cloud.cfg`
- `hostnamectl set-hostname chef12.cumulocity.com --static`
- `reboot`
- `cd /tmp`
- `wget https://packages.chef.io/files/stable/chef-server/12.15.8/el/7/chef-server-core-12.15.8-1.el7.x86_64.rpm`
- `rpm -ivh chef-server-core-*.rpm`
- `chef-server-ctl reconfigure`
- `chef-server-ctl install chef-manage`
- `opscode-manage-ctl reconfigure`
- `chef-server-ctl reconfigure`
- `mkdir /root/.chef/`
- `chef-server-ctl user-create <username> Admin Chef12 C8Y chef12@cumulocity.com <password> --filename /root/.chef/<username>.pem`
- `chef-server-ctl org-delete cumulocity-devel`
- `chef-server-ctl org-create cumulocity-devel 'Cumulocity Development' --filename /root/.chef/cumulocity-devel-validator.pem`
- `chef-server-ctl org-user-add cumulocity-devel <username> --admin`

Use the following files to create your organization on the local chef's workstation:
- `cat /root/.chef/cumulocity-devel-validator.pem`
- `cat /root/.chef/<username>.pem`

Put these files into cumulocity-chef/.chef/organizations/cumulocity-devel
Add the following entry in cumulocity-chef/.chef/organizations/index.json
cumulocity-devel:
  node_name: <username>
  client_key: <username>.pem
  pub: https://chef12.cumulocity.com/organizations/cumulocity-devel
  knife:
    ssh_key_name: <name-of-the-AWS-region-key.pem>
    aws_access_key_id: XXXXXX
    aws_secret_access_key: YYYYYYY

### chef-server-12  (Felix' chef server)
but there is already a running chef-server-12 ready to use.
- go to `https://52.16.90.217`
- username `cli`
- password `12345678`


## setup workstation
this chef-repo is a ruby based project and needs ruby and gems(plugins) to work.
to install ruby you need a ruby version manager like rbenv or rvm.
you can find the needed ruby version in file ./.ruby-version
after the installation of ruby you need a gem management gem called bundler.
run `gem install bundler` to install bundler. after that you can manage your gems via the file ./Gemfile
and by installing these gems via `bundle install`.
after all the gems are installed you can test the connection between the chef-repo and the chef-server with knife.
run `bundle exec knife node list` this will ask the chef-server for registered nodes on the chef-server.
(the bundler exec means 'run this command with local gems, not with the system gems')
it will ask you in which organization you are running knife. run `export ORGNAME=myorg` to use the organization that is already installed on the existing chef-server-12. you can change or add organization settings in ./.chef/organizations/index.yml
`bundle exec knife node list` should return now with no error.  AWS credentials are also kept in organization's index.yml

## alternative setup workstation
instead of installing an alternative ruby version and install component piece by piece, you can alternatively download the latest chefdk package from https://downloads.chef.io/chefdk (latest tested version is 2.3.4), install it and install/update knife-ec2 with 'gem install knife-ec2' command as root.
This will install all the main components and you will not need to use 'bundle exec' before every command.

## creating and provisioning new nodes
with knife you can provisioning

There are two ways to create a cluster, via knife(manually) or via chef-provisioning(automatic).
lets start with knife


## knife
run all commands from this repo

- set organization `export ORGNAME=myorg`
- create a ec2 server with knife(more about knife-ec2 in the links section) `bundle exec knife ec2 server create -r "role[cumulocity-base]" -E production -N my-node`
- upload the core vault(more about chef-vault in the links section) `bundle exec knife vault create secrets core -A 'cli' -M client -S 'name:my-*' -J .chef/secrets/core.json`
- add tag `bundle exec knife tag create my-dbs standalone:mongod7:`
- add role `bundle exec knife role run_list add cumulocity-dev-singlenode my-node`
- run chef-client on all nodes that starts with the name 'my-' in production `bundle exec knife ssh 'name:my-* AND chef_environment:production' 'sudo chef-client'`



## chef-provisioning
more about chef-provisioning in the links section at the bottom of this file.

##### start a full cluster
- change step to 1 `provisioning/aws/full.rb`
- update the cluster `bundle exec chef-client -z provisioning/aws/full.rb`
- upload the core secrets `bundle exec knife vault create secrets core -A 'cli' -M client -S 'name:devops_production_*' -J .chef/secrets/core.json`
- change step to 2 `provisioning/aws/full.rb`
- run it again to connect everthing `bundle exec chef-client -z provisioning/aws/full.rb`
- repeat until step 5
- get core node ip `bundle exec knife ec2 server list`
- ssh to core node and stop karaf `sudo /etc/init.d/cumulocity-core-karaf stop`
- than start karaf and wait 30 secends for startup `sudo /etc/init.d/cumulocity-core-karaf start`
- test if karaf is running by `curl -X GET http://localhost:80/tenant/health` it should return `{}`
- test if the certificate is working by `wget http://localhost:8181/platform` you should get a `401 Unauthorized`
- change user `sudo su`
- cd into the ui install directory `cd /webapps/2Install`
- download the GUIpackage `wget https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/366d235f0648/8.2.0.zip`
- test if the installation is done by open the ontop_lb ip in your browser. you should see the cumulocity default web GUI

##### scale core
- increase core_count in `provisioning/aws/full.rb`
- update the cluster `bundle exec chef-client -z provisioning/aws/full.rb`
- it will fail becouse the new node dont have access to the core secret
- delete the core secret `bundle exec knife data bag delete secrets -y`
- upload core secred again `bundle exec knife vault create secrets core -A 'cli' -M client -S 'name:devops_production_*' -J .chef/secrets/core.json`
- update the cluster `bundle exec chef-client -z provisioning/aws/full.rb`

##### stop a cluster
- change step to 0 `provisioning/aws/full.rb`
- update the cluster `bundle exec chef-client -z provisioning/aws/full.rb`
- delete the secrets `bundle exec knife data bag delete secrets -y`



### make changes in the cumulocity cookbook.
the cumulocity-cookbook is not part of this chef-repo the reason is that some external partner can use their own chef-repo.
the cumulocity-cookbook shoud be placed like in the ./Berksfile described.
berkshelf(more about berkshelf in the links section) is managing the external cookbook and his dependencies.
so if you what to add or update a cookbook like java or chef-client you can do this in the cumulocity-cookbook metadata.rb.
than you can run from this cumulocity-chef repo `bundle exec berks install` to download the community cookbooks from the supermarket.
to upload the cumulocity cookbooks run `bundle exec berks upload cumulocity --force` the force will ignore the version number that is already on the chef-server and will reupload the cumulocity cookbook with his dependencie community cookbooks.



## knife cheat sheet
run all commands from this repo

###### add ssh key
- `chmod 600 .chef/keys/chef_cumulocity.pem && ssh-add .chef/keys/chef_cumulocity.pem`

###### Upload environment
- `bundle exec knife environment from file environments/production.rb`

###### Upload Roles
- `bundle exec knife upload roles`

###### Upload cookbook
- `bundle exec berks upload cumulocity --force`

###### Create and upload vault data bag
- `bundle exec knife vault create secrets core -A 'cli,ffaerber' -M client -S 'name:devops_production_core_*' -J .chef/secrets/core.json`

###### Update vault data bag by adding new clients or nodes
- `bundle exec knife vault update secrets core -A 'cli' -M client -S 'name:*' -J .chef/secrets/core.json`

###### create and Upload databags
- `bundle exec knife data bag create users_cumulocity`
- `bundle exec knife data bag from file users_cumulocity -a`

###### Create a node
- `bundle exec knife ec2 server create -r "role[cumulocity-base],role[cumulocity-mongo]" -E production`

###### Create a node with vault auto-update
- `knife ec2 server create -r "role[cumulocity-dev-singlenode]" -E luca-non-production -i .chef/keys/chef_cumulocity.pem -N luca_dev --bootstrap-vault-item secrets:core`

###### Delete a node
- `bundle exec knife ec2 server delete i-089c27e666415e4b0 --purge -y`

###### Add tags to a node
- `bundle exec knife tag create i-0c8648e8 mytag`

###### Search nodes
- `bundle exec knife search node 'chef_environment:production AND role:cumulocity-common-cores'`

###### run chef-client on Nodes
- `bundle exec knife ssh 'role:cumulocity-base AND chef_environment:production' 'sudo chef-client'`



# links
- knife-ec2 https://github.com/chef/knife-ec2
- chef-vault https://blog.chef.io/2013/09/19/managing-secrets-with-chef-vault/
- chef-provisioning https://github.com/chef/chef-provisioning
- berkshelf https://docs.chef.io/berkshelf.html
- rbenv https://github.com/rbenv/rbenv

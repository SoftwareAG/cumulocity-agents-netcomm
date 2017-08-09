# Get started
this documentation is for installing the cumulocity software on a centos7 OS with chef12.
first you need a chef-server 12

##### Install Chef-Server
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

but there is already a running chef-server-12 ready to use.

##### chef-server-12
- go to `https://52.16.90.217`
- username `cli`
- password `12345678`

There are two ways to create a cluster, via knife(manually) or via chef-provisioning(automatic).

## chef-provisioning

there are three cluster types.

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






## knife
add ssh key `chmod 600 .chef/keys/chef_cumulocity.pem && ssh-add .chef/keys/chef_cumulocity.pem`

create db `bundle exec knife ec2 server create -r "role[cumulocity-base],role[cumulocity-sql-db],role[cumulocity-mongo],role[cumulocity-mongo-standalone],role[cumulocity-common-dbs-standalone-mongo],role[cumulocity-mongo-configsvr]" -E production -N my-dbs`

add tag `bundle exec knife tag create my-dbs standalone:mongod7:`

create core `bundle exec knife ec2 server create -r "role[cumulocity-base],role[cumulocity-common-cores],role[cumulocity-cep-server],role[cumulocity-mn-active-core],role[cumulocity-internal-lb],role[cumulocity-external-lb]" -E production -N my-core`

create ontop_lb `bundle exec knife ec2 server create -r "role[cumulocity-base],role[cumulocity-external-lb],role[cumulocity-ontop-lb]" -E production -N my-ontop_lb`


##### update nodes
`bundle exec knife ssh 'name:my-* AND chef_environment:production' 'sudo chef-client'`



## knife cheat sheet

##### add ssh key
- `chmod 600 .chef/keys/chef_cumulocity.pem && ssh-add .chef/keys/chef_cumulocity.pem`

##### Upload environment
- `bundle exec knife environment from file environments/production.rb`

##### Upload Roles
- `bundle exec knife upload roles`

##### Upload cookbook
- `bundle exec berks upload cumulocity --force`

##### Create and upload vault data bag
- `bundle exec knife vault create secrets core -A 'cli,ffaerber' -M client -S 'name:devops_production_core_*' -J .chef/secrets/core.json`

##### create and Upload databags
- `bundle exec knife data bag create users_cumulocity`
- `bundle exec knife data bag from file users_cumulocity -a`

##### Create a node
- `bundle exec knife ec2 server create -r "role[cumulocity-base],role[cumulocity-mongo]" -E production`

##### Delete a node
- `bundle exec knife ec2 server delete i-089c27e666415e4b0 --purge -y`

##### Add tags to a node
- `bundle exec knife tag create i-0c8648e8 mytag`

##### Search nodes
- `bundle exec knife search node 'chef_environment:production AND role:cumulocity-common-cores'`

##### run chef-client on Nodes
- `bundle exec knife ssh 'role:cumulocity-base AND chef_environment:production' 'sudo chef-client'`

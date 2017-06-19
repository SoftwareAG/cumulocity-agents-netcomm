# add ssh key
- `chmod 600 .chef/keys/chef_cumulocity.pem && ssh-add .chef/keys/chef_cumulocity.pem`

# Upload environment
- `bundle exec knife environment from file environments/production.rb`

# Upload Roles
- `bundle exec knife upload roles`

# Upload cookbook
- `bundle exec berks upload cumulocity --force`

# Upload databags
- `bundle exec knife data bag from file users_cumulocity -a`

# Create a node
- `bundle exec knife ec2 server create -r "role[cumulocity-base],role[cumulocity-mongo]" -E production`

# Delete a node
- `bundle exec knife ec2 server delete i-034a033eb794592f4 --purge -y`

# Add tags to a node
- `bundle exec knife tag create i-0c8648e8 migrate sidekiq whenever`

# Search nodes
- `bundle exec knife search node 'chef_environment:staging AND role:buzzn'`

# run chef-client on Nodes
- `bundle exec knife ssh 'role:cumulocity-base AND chef_environment:production' 'sudo chef-client'`

# deploy a small cluster
- start the cluster `bundle exec chef-client -z provisioning/aws/small.rb`
- run it again to connect everthing `bundle exec chef-client -z provisioning/aws/small.rb`
- get core node ip `bundle exec knife ec2 server list`
- ssh to core node and stop karaf `sudo /etc/init.d/cumulocity-core-karaf stop`
- than start karaf and wait 30 secends for startup `sudo /etc/init.d/cumulocity-core-karaf start`
- test if karaf is running by `curl -X GET http://localhost:80/tenant/health` it should return `{}`
- change user `sudo su`
- cd into the ui install directory `cd /webapps/2Install`
- download the GUIpackage `wget https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/366d235f0648/8.2.0.zip`
- test if the instalation is done by open the ontop_lb ip in your browser. you should see the cumulocity default web GUI


# Install Chef-Server
- `ssh -i '.chef/keys/ffaerber.pem' centos@52.16.90.217`
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
- copy ffaerber.pem and myorg-validator.pem in your chef-repo under .chef
- `knife ssl fetch ` for info to fix the ssl errors

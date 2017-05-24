
# Install Chef-Server
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
- `chef-server-ctl user-create ffaerber Felix Faerber ffaerber@gmail.com 12345678 --filename /root/.chef/ffaerber.pem`
- `chef-server-ctl org-create myorg 'MyOrganization' --association_user ffaerber --filename /root/.chef/myorg-validator.pem`
- copy ffaerber.pem and myorg-validator.pem in your chef-repo under .chef
- `knife ssl fetch ` for info to fix the ssl errors

# add ssh key
- `chmod 600 .chef/keys/ffaerber.pem && ssh-add .chef/keys/ffaerber.pem`

# Upload environment
- `bundle exec knife environment from file environments/production.rb`

# Upload Roles
- `bundle exec knife upload roles`

# Upload cookbooks
- `bundle exec berks upload --force`

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

# create a full cluster
- `bundle exec chef-client -z provisioning/aws/full.rb`

# create a small cluster
- `bundle exec chef-client -z provisioning/aws/small.rb`

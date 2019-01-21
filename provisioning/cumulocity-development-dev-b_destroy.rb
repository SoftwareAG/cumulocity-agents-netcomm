require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-dev-b'

with_chef_environment environment
with_chef_server(
  "https://chef12.cumulocity.com/organizations/cumulocity-stagings",
  client_name: Chef::Config[:node_name],
  signing_key_filename: Chef::Config[:client_key]
)

with_machine_options({
  convergence_options: {
    ssl_verify_mode: 'verify_none',
    chef_version: "12.21.31"
  },
  ssh_username: "centos"
})

dev_id = "dev-b"

### END OF CLUSTER CONFIGURATION ###
machine "#{dev_id}" do
  action :destroy
end

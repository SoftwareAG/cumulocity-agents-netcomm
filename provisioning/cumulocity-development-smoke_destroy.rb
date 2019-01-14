require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-smoke'

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

add_machine_options(
  bootstrap_options: {
    key_name: 'chef_cumulocity',
    instance_type: 'm3.medium',
    image_id: 'ami-0597ae12f89cbc55c',
    subnet_id: 'subnet-c477d0bf',
    security_group_ids: ['sg-02ed752df3d92fa8f']
  }
)

private_ips = "172.31.18.177"
flavour_for_dev = "m3.large"
dev_id = "smoke"

### END OF CLUSTER CONFIGURATION ###
machine "#{dev_id}" do
  action :destroy
end

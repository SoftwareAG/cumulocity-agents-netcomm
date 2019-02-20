require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-dev-g-nonprod'

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

private_ips = "172.31.18.178"
flavour_for_dev = "m3.large"
dev_id = "dev-g"

### END OF CLUSTER CONFIGURATION ###
machine "#{environment}_#{dev_id}" do
    add_machine_options(
        bootstrap_options: {
            # private_ip_address: "#{private_ips}",
            instance_type: "#{flavour_for_dev}"
        }
    )
    tags ["standalone:mongod7:"]
    attributes(
      ddclient: {
        domain: "#{dev_id}.cumulocity.com"
      }
    )
    recipe 'cumulocity-ddclient'
    role 'cumulocity-dev-singlenode' 
end

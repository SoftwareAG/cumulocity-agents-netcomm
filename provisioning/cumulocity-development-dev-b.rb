require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-dev-b-nonprod'
private_ips = "172.31.18.177"
flavour_for_dev = "c4.xlarge"
dev_id = "dev-b"
volume_size = 30

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
    instance_type: "#{flavour_for_dev}",
    image_id: 'ami-0597ae12f89cbc55c',
    subnet_id: 'subnet-c477d0bf',
    security_group_ids: ['sg-02ed752df3d92fa8f']
  }
)



### END OF CLUSTER CONFIGURATION ###
machine "#{environment}_#{dev_id}" do
    add_machine_options(
        bootstrap_options: {
            # private_ip_address: "#{private_ips}",
            instance_type: "#{flavour_for_dev}"
            block_device_mappings: [{
              'device_name': '/dev/sda1',
              'ebs': {
                'volume_size': "#{volume_size}",
                'delete_on_termination': true }
          }]
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

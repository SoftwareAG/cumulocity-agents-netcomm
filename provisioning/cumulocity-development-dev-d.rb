require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-dev-d-nonprod'
private_ips = "172.31.18.177"
flavour_for_dev = "c4.xlarge"
dev_id = "dev-d"
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
  ssh_username: "centos",
})

add_machine_options({
  bootstrap_options: {
    key_name: 'chef_cumulocity',
    instance_type: "#{flavour_for_dev}",
    block_device_mappings: [{
      'device_name': '/dev/sda1',
      'ebs': {
       'volume_size': 30,
       'delete_on_termination': true }
    }],
    # image_id: 'ami-e499ae0f',
    image_id: 'ami-0597ae12f89cbc55c',
    subnet_id: 'subnet-c477d0bf',
    security_group_ids: ['sg-02ed752df3d92fa8f']
  },
  create_timeout: 360,
  start_timeout: 360,
  ssh_timeout: 360
})

### END OF CLUSTER CONFIGURATION ###
step = ENV['STEP'].to_i || 1

ruby_block 'next-step-is' do
  block do
  puts ""
  puts "===================================="
  puts "T h e  c u r r e n t  s t e p  is  #{step}/4"
  puts "===================================="
  puts ""
  sleep 4
  end
end

machine "#{dev_id}" do
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
        domain: "#{dev_id}.cumulocity.com",
        login:  "13107q-m2mdyndns",
        password: "p2AN8xG9)e.K",
        use: "web, web=checkip.dyndns.com/, web-skip='IP Address'",
        server: "members.dyndns.org"
      }
    )
    if step > 1
      recipe 'cumulocity-ddclient'
      role 'cumulocity-base'
      recipe 'cumulocity::mongo'
      role 'cumulocity-common-cores'
      role 'cumulocity-kubernetes' if step >= 3
      recipe 'cumulocity::karaf_dev-x-agents' if step >= 3
      role 'cumulocity-mn-active-core' if step >= 4
    end
end

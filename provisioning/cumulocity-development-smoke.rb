require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-smoke-nonprod'

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
for step in 1..2
  machine "#{dev_id}" do
      add_machine_options(
          bootstrap_options: {
              # private_ip_address: "#{private_ips}",
              instance_type: "#{flavour_for_dev}"
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
      recipe 'cumulocity-ddclient'
      role 'cumulocity-base'
      recipe 'cumulocity::mongo'
      role 'cumulocity-common-cores'
      role 'cumulocity-kubernetes'
      recipe 'cumulocity::karaf_dev-x-agents'
      role 'cumulocity-mn-active-core' if step == 2
  end
end

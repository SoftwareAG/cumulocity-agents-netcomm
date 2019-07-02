require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

dev_id = ENV['DEVXID']
environment  = "cumulocity-development-#{dev_id}-nonprod"

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
  create_timeout: 360,
  start_timeout: 360,
  ssh_timeout: 360
})

machine "#{dev_id}" do
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
   action :ready
end

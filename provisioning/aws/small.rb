require 'chef/provisioning'

running = false
auto_batch_machines = false
with_chef_environment 'production'
with_driver 'fog:AWS:cumulocity'

with_chef_server(
  "https://ec2-52-16-90-217.eu-west-1.compute.amazonaws.com/organizations/myorg",
  client_name: Chef::Config[:node_name],
  signing_key_filename: Chef::Config[:client_key]
)

with_machine_options({
  convergence_options: { ssl_verify_mode: 'verify_none' },
  ssh_username: "centos"
})

add_machine_options(
  bootstrap_options: {
    key_name: 'ffaerber',
    flavor_id: 'm4.large',
    image_id: 'ami-0d063c6b'
  })

project = 'felix'

if running

  machine "#{project}_dbs" do
    role 'cumulocity-base'
    role 'cumulocity-sql-db'
    role 'cumulocity-mongo'
    role 'cumulocity-mongo-configsvr'
    tag 'standalone:mongod7:'
  end

else
  machine "#{project}_dbs" do
    action :destroy
  end
end

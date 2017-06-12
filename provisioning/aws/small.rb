require 'chef/provisioning'

running = true
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
    key_name: 'chef_cumulocity',
    flavor_id: 'm4.large',
    image_id: 'ami-ac524fca'
  })

project = 'felix'

if running

  machine "#{project}_dbs" do
    role 'cumulocity-base'
    role 'cumulocity-sql-db'
    role 'cumulocity-mongo'
    role 'cumulocity-mongo-standalone'
    role 'cumulocity-common-dbs-standalone-mongo'
    role 'cumulocity-mongo-configsvr'
    tag 'standalone:mongod7:'
  end

  machine "#{project}_core_master" do
    role 'cumulocity-base'
    role 'cumulocity-external-lb'
    role 'cumulocity-internal-lb'
    role 'cumulocity-common-cores'
    role 'cumulocity-cep-server'
    role 'cumulocity-mn-active-core'
  end

  machine "#{project}_ontop_lb" do
    role 'cumulocity-base'
    role 'cumulocity-external-lb'
    role 'cumulocity-ontop-lb'
  end

else
  machine "#{project}_dbs" do
    action :destroy
  end
  machine "#{project}_core_master" do
    action :destroy
  end
  machine "#{project}_ontop_lb" do
    action :destroy
  end
end

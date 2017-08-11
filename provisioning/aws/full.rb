require 'chef/provisioning'

environment = 'production'
with_chef_environment environment
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
  }
)

project     = "devops_#{environment}"
step        = 0 # step from 0 to 5
core_count  = 2


if step >= 1
  machine_batch do
    machine "#{project}_mongo_cluster_rs01" do
      role 'cumulocity-mongo'  if step >= 2
      role 'cumulocity-mongo-configsvr' if step >= 2
      if step >= 3
        tag 'replicaset:rs01:P'
        tag 'replicaset:rs02:A'
        tag 'replicaset:rs03:S'
      end
    end
    machine "#{project}_mongo_cluster_rs02" do
      role 'cumulocity-mongo' if step >= 2
      role 'cumulocity-mongo-configsvr' if step >= 2
      if step >= 3
        tag 'replicaset:rs01:S'
        tag 'replicaset:rs02:P'
        tag 'replicaset:rs03:A'
      end
    end
    machine "#{project}_mongo_cluster_rs03" do
      role 'cumulocity-mongo' if step >= 2
      role 'cumulocity-mongo-configsvr' if step >= 2
      if step >= 3
        tag 'replicaset:rs01:A'
        tag 'replicaset:rs02:S'
        tag 'replicaset:rs03:P'
      end
    end
    machine "#{project}_sql_db" do
      role 'cumulocity-base'
      role 'cumulocity-sql-db' if step >= 2
    end
  end
  1.upto(core_count) do |i|
    machine "#{project}_core_#{i}" do
      role 'cumulocity-base'
      if step >= 4
        role 'cumulocity-common-cores'
        role 'cumulocity-mn-active-core'
        role 'cumulocity-internal-lb'
        role 'cumulocity-external-lb'
      end
    end
  end
  machine "#{project}_cep" do
    role 'cumulocity-base'
    if step >= 5
      role 'cumulocity-cep-server'
      role 'cumulocity-internal-lb'
    end
  end
  machine "#{project}_ontop_lb" do
    role 'cumulocity-base'
    if step >= 5
      role 'cumulocity-external-lb'
      role 'cumulocity-ontop-lb'
    end
  end
else
  machine "#{project}_mongo_cluster_rs01" do
    action :destroy
  end
  machine "#{project}_mongo_cluster_rs02" do
    action :destroy
  end
  machine "#{project}_mongo_cluster_rs03" do
    action :destroy
  end
  machine "#{project}_sql_db" do
    action :destroy
  end
  1.upto(core_count) do |i|
    machine "#{project}_core_#{i}" do
      action :destroy
    end
  end
  machine "#{project}_cep" do
    action :destroy
  end
  machine "#{project}_ontop_lb" do
    action :destroy
  end
end

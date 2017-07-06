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

running     = true
first_run   = true
core_count  = 3
project     = "devops_#{environment}"

if running
  machine_batch do
    machine "#{project}_mongo_cluster_rs01" do
      role 'cumulocity-mongo'
      role 'cumulocity-mongo-configsvr'
      if !first_run
        tag 'replicaset:rs01:P'
        tag 'replicaset:rs02:A'
        tag 'replicaset:rs03:S'
      end
    end
    machine "#{project}_mongo_cluster_rs02" do
      role 'cumulocity-mongo'
      role 'cumulocity-mongo-configsvr'
      if !first_run
        tag 'replicaset:rs01:S'
        tag 'replicaset:rs02:P'
        tag 'replicaset:rs03:A'
      end
    end
    machine "#{project}_mongo_cluster_rs03" do
      role 'cumulocity-mongo'
      role 'cumulocity-mongo-configsvr'
      if !first_run
        tag 'replicaset:rs01:A'
        tag 'replicaset:rs02:S'
        tag 'replicaset:rs03:P'
      end
    end
  end
  machine "#{project}_sql_db" do
    role 'cumulocity-base'
    role 'cumulocity-sql-db'
  end
  1.upto(core_count) do |i|
    machine "#{project}_core_#{i}" do
      role 'cumulocity-base'
      role 'cumulocity-common-cores'
      role 'cumulocity-mn-active-core'
      role 'cumulocity-internal-lb'
      role 'cumulocity-external-lb'
    end
  end
  machine "#{project}_cep" do
    role 'cumulocity-base'
    role 'cumulocity-cep-server'
  end
  machine "#{project}_ontop_lb" do
    role 'cumulocity-base'
    role 'cumulocity-external-lb'
    role 'cumulocity-ontop-lb'
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

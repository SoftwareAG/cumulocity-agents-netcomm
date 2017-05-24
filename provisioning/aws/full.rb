require 'chef/provisioning'

running_cluster = false
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

add_machine_options( bootstrap_options: {key_name: 'ffaerber', flavor_id: 'm4.large', image_id: 'ami-0d063c6b' })



if running_cluster


  machine_batch do
    machine "mongo_cluster_rs01" do
      role 'cumulocity-mongo'
      role 'cumulocity-mongo-configsvr'
      tag 'replicaset:rs01:P'
      tag 'replicaset:rs02:A'
      tag 'replicaset:rs03:S'
    end
    machine "mongo_cluster_rs02" do
      role 'cumulocity-mongo'
      role 'cumulocity-mongo-configsvr'
      tag 'replicaset:rs01:S'
      tag 'replicaset:rs02:P'
      tag 'replicaset:rs03:A'
    end
    machine "mongo_cluster_rs03" do
      role 'cumulocity-mongo'
      role 'cumulocity-mongo-configsvr'
      tag 'replicaset:rs01:A'
      tag 'replicaset:rs02:S'
      tag 'replicaset:rs03:P'
    end
  end


else
  machine "mongo_cluster_rs01" do
    action :destroy
  end
  machine "mongo_cluster_rs02" do
    action :destroy
  end
  machine "mongo_cluster_rs03" do
    action :destroy
  end
end

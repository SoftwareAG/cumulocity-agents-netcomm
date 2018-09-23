require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-staging-jenkins-nonprod'

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

### CONFIGURE YOUR CLUSTER BELOW ###

c8ycore_count = 3
flavour_for_c8ycore       = "c4.xlarge"
private_ips_for_c8ycore   = ["172.31.18.211","172.31.18.212","172.31.18.213"]

ontoplb_count = 1
flavour_for_ontoplb       = "m4.large"
private_ips_for_ontoplb   = ["172.31.18.247","172.31.18.248","172.31.18.249"]

ssagent_count = 1
flavour_for_ssagent       = "m4.large"
private_ips_for_ssagent   = ["172.31.18.250"]
ssagent_tags  = [
        ["sms-gateway-server","ssl-management-agent-server","lwm2m-agent-server","impact-agent-server"],
]

mongodb_count = 3
flavour_for_mongodb       = "c4.2xlarge"
private_ips_for_mongodb   = ["172.31.18.111","172.31.18.112","172.31.18.113"]
mongodb_cluster = [
        ["configreplset:config9:P","replicaset:rs01:P","replicaset:rs02:S","replicaset:rs03:A"],
        ["configreplset:config9:S","replicaset:rs01:A","replicaset:rs02:P","replicaset:rs03:S"],
        ["configreplset:config9:S","replicaset:rs01:S","replicaset:rs02:A","replicaset:rs03:P"]
]

kubernetes_master_count   = 3
flavour_for_masters       = "m4.large"
private_ips_for_masters   = ["172.31.18.55","172.31.18.56","172.31.18.57"]

kubernetes_worker_count   = 3
flavour_for_workers       = "c4.xlarge"
private_ips_for_workers   = ["172.31.18.61","172.31.18.62","172.31.18.63"]


### END OF CLUSTER CONFIGURATION ###

machine_batch  do
    action :destroy
    1.upto(mongodb_count) do |i|
        machine "#{environment}_mongodb#{i}" do
            
        end
    end

    1.upto(c8ycore_count) do |i|
        machine "#{environment}_core#{i}" do
            
        end
    end

    1.upto(ontoplb_count) do |i|
        machine "#{environment}_lb#{i}" do
            
        end
    end

    1.upto(ssagent_count) do |i|
        machine "#{environment}_agents" do
            
        end
    end

    1.upto(kubernetes_master_count) do |i|
        machine "#{environment}_master_#{i}" do
            
        end
    end

    1.upto(kubernetes_worker_count) do |i|
        machine "#{environment}_worker_#{i}" do
            
        end
    end
end
# machine "#{environment}_core"
# machine "#{environment}_agents"
# machine "#{environment}_ontop_lb"
# action :destroy
# end



require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity-stagings:eu-west-1'

environment  = 'cumulocity-staging-develop-nonprod'

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
    instance_type: 'c4.2xlarge',
    image_id: 'ami-60206719',
    subnet_id: 'subnet-8f98a6ea',
    security_group_ids: ['sg-6ddd4e09']
  }
)

### CONFIGURE YOUR CLUSTER BELOW ###

c8ycore_count = 2
flavour_for_c8ycore       = "c4.2xlarge"
volume_size_for_c8ycore   = 60
private_ips_for_c8ycore   = ["172.31.6.211","172.31.6.212","172.31.6.213","172.31.6.214","172.31.6.215","172.31.6.216","172.31.6.217","172.31.6.218","172.31.6.219","172.31.6.220"]

ontoplb_count = 1
flavour_for_ontoplb       = "c4.large"
volume_size_for_ontoplb   = 20
private_ips_for_ontoplb   = ["172.31.6.247","172.31.6.248","172.31.6.249"]

ssagent_count = 1
flavour_for_ssagent       = "c4.2xlarge"
volume_size_for_ssagent   = 20
private_ips_for_ssagent   = ["172.31.6.250"]
ssagent_tags  = [
        ["ssl-management-agent-server"],
]

mongodb_count = 3
flavour_for_mongodb       = "c4.2xlarge"
volume_size_for_mongodb   = 100
private_ips_for_mongodb   = ["172.31.6.111","172.31.6.112","172.31.6.113"]
mongodb_cluster = [
        ["configreplset:config9:P","replicaset:rs01:P","replicaset:rs02:A","replicaset:rs03:S"],
        ["configreplset:config9:S","replicaset:rs01:S","replicaset:rs02:P","replicaset:rs03:A"],
        ["configreplset:config9:S","replicaset:rs01:A","replicaset:rs02:S","replicaset:rs03:P"]
]

kubernetes_master_count   = 3
flavour_for_masters       = "c4.2xlarge"
volume_size_for_masters   = 12
private_ips_for_masters   = ["172.31.6.55","172.31.6.56","172.31.6.57"]

kubernetes_worker_count   = 2
flavour_for_workers       = "c4.4xlarge"
volume_size_for_workers   = 100
private_ips_for_workers   = ["172.31.6.61","172.31.6.62","172.31.6.63","172.31.6.64","172.31.6.65"]


### END OF CLUSTER CONFIGURATION ###


initStep = Integer(::File.read("/tmp/.ps-#{environment}.steps").chomp) rescue 1
for step in initStep..7

  if step >= 1

  current_step = lambda {step}
  file "/tmp/.ps-#{environment}.steps" do
        content  "#{current_step.call}"
  end

  ruby_block 'next-step-is' do
        block do
        current_step = ::File.read("/tmp/.ps-#{environment}.steps").chomp
        puts ""
        puts "===================================="
        puts "T h e  c u r r e n t  s t e p  is  #{current_step}"
        puts "===================================="
        puts ""
        sleep 4
        only_if { ::File.exist?("/tmp/.ps-#{environment}.steps") }
        end
  end


  machine_batch do

    1.upto(mongodb_count) do |i|
        machine "#{environment}_mongodb#{i}" do
        add_machine_options(
            bootstrap_options: {
                private_ip_address: "#{private_ips_for_mongodb[i-1]}",
                instance_type: "#{flavour_for_mongodb}",
                block_device_mappings: [{
                    'device_name': '/dev/sda1',
                    'ebs': {
                      'volume_size': "#{volume_size_for_mongodb}",
                      'delete_on_termination': true }
                }]

            }
        )
        if step > 1
            role 'cumulocity-base'
            role 'cumulocity-mongo'
            role 'cumulocity-mongo-configsvr'
            mongodb_cluster[i-1].each do |m_tag|
                tag m_tag
            end
        end
        end
    end

    1.upto(c8ycore_count) do |i|
        machine "#{environment}_core#{i}" do
        add_machine_options(
            bootstrap_options: {
                private_ip_address: "#{private_ips_for_c8ycore[i-1]}",
                instance_type: "#{flavour_for_c8ycore}",
                block_device_mappings: [{
                    'device_name': '/dev/sda1',
                    'ebs': {
                      'volume_size': "#{volume_size_for_c8ycore}",
                      'delete_on_termination': true }
                }]
            }
        )
        if step > 1
            role 'cumulocity-base'
            if step >= 4
                role 'cumulocity-common-cores'
                role 'cumulocity-mn-active-core' if step == 6 and i == 1
                role 'cumulocity-mn-active-core' if step == 7
                role 'cumulocity-kubernetes' if step == 5
            end
        end
        end
    end

    1.upto(ontoplb_count) do |i|
        machine "#{environment}_lb#{i}" do
        add_machine_options(
            bootstrap_options: {
                private_ip_address: "#{private_ips_for_ontoplb[i-1]}",
                instance_type: "#{flavour_for_ontoplb}",
                block_device_mappings: [{
                    'device_name': '/dev/sda1',
                    'ebs': {
                      'volume_size': "#{volume_size_for_ontoplb}",
                      'delete_on_termination': true }
                }]

            }
        )
            if step > 1
                role 'cumulocity-base'
                role 'cumulocity-ontop-lb' if step == 6
            end
        end
    end

    1.upto(ssagent_count) do |i|
        machine "#{environment}_agents" do
        add_machine_options(
            bootstrap_options: {
                private_ip_address: "#{private_ips_for_ssagent[i-1]}",
                instance_type: "#{flavour_for_ssagent}",
                block_device_mappings: [{
                    'device_name': '/dev/sda1',
                    'ebs': {
                      'volume_size': "#{volume_size_for_ssagent}",
                      'delete_on_termination': true }
                }]

            }
        )
            if step > 1
                role 'cumulocity-base'
                role 'cumulocity-ssagents'
                role 'cumulocity-internal-lb'
                if step >= 6
                    recipe 'cumulocity::karaf_notification'
                    ssagent_tags[i-1].each do |m_tag|
                        tag m_tag
                    end
                end
            end
        end
    end

    1.upto(kubernetes_master_count) do |i|
        machine "#{environment}_master_#{i}" do
        add_machine_options(
            bootstrap_options: {
                private_ip_address: "#{private_ips_for_masters[i-1]}",
                instance_type: "#{flavour_for_masters}",
                block_device_mappings: [{
                    'device_name': '/dev/sda1',
                    'ebs': {
                      'volume_size': "#{volume_size_for_masters}",
                      'delete_on_termination': true }
                }]

            }
        )
        role 'cumulocity-base'
        if step > 1
            role 'cumulocity-kubernetes'
            node_tags = []
            node_tags << 'etcd'
            node_tags << 'etcd-init' if step == 3
            node_tags << 'k8s-master'
            node_tags << 'k8s-master-main' if i == 1
            node_tags << 'k8s-master-init' if step == 4 && i == 1
            node_tags << 'k8s-master-add' if step >= 6 && i != 1
            tags node_tags
            recipe 'cumulocity-kubernetes::certs_upload' if step == 5 && i == 1
        end
        end
    end

    1.upto(kubernetes_worker_count) do |i|
        machine "#{environment}_worker_#{i}" do
        add_machine_options(
            bootstrap_options: {
                private_ip_address: "#{private_ips_for_workers[i-1]}",
                instance_type: "#{flavour_for_workers}",
                block_device_mappings: [{
                    'device_name': '/dev/sda1',
                    'ebs': {
                      'volume_size': "#{volume_size_for_workers}",
                      'delete_on_termination': true }
                }]

            }
        )
        role 'cumulocity-base'
        if step > 1
            role 'cumulocity-kubernetes'
            node_tags = []
            node_tags << 'k8s-worker' if step >= 5
            tags node_tags
        end
        end
    end
  end
else
#  machine_batch do
#    machine "#{environment}_mongo_standalone"
#    machine "#{environment}_core"
#    machine "#{environment}_agents"
#    machine "#{environment}_ontop_lb"
#    action :destroy
#  end



end

end

file "/tmp/.ps-#{environment}.steps" do
    action :delete
end

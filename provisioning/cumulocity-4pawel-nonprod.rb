require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-4pawel-nonprod'

with_chef_environment environment
with_chef_server(
  "https://chef12.cumulocity.com/organizations/cumulocity-devel",
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

c8ycore_count = 1
flavour_for_c8ycore       = "c5.xlarge"
private_ips_for_c8ycore   = ["172.31.29.60","172.31.29.61","172.31.29.62","172.31.29.63","172.31.29.64","172.31.29.65"]

ontoplb_count = 1
flavour_for_ontoplb       = "m5.large"
private_ips_for_ontoplb   = ["172.31.29.66","172.31.29.67","172.31.29.68"]

ssagent_count = 1
flavour_for_ssagent       = "m5.large"
private_ips_for_ssagent   = ["172.31.29.69"]
ssagent_tags  = [
        ["sms-gateway-server","ssl-management-agent-server","lwm2m-agent-server","impact-agent-server"],
]

mongodb_count = 6
flavour_for_mongodb       = "m5.xlarge"
private_ips_for_mongodb   = ["172.31.29.70","172.31.29.71","172.31.29.72","172.31.29.73","172.31.29.74","172.31.29.75"]
mongodb_cluster = [
        ["configreplset:config9:P","replicaset:rs01:P","replicaset:rs02:S","replicaset:rs03:A"],
        ["configreplset:config9:S","replicaset:rs01:A","replicaset:rs02:P","replicaset:rs03:S"],
        ["configreplset:config9:S","replicaset:rs01:S","replicaset:rs02:A","replicaset:rs03:P"],
        [],
        [],
        [],
        # ["replicaset:rs04:P","replicaset:rs05:S","replicaset:rs06:S"],
        # ["replicaset:rs04:S","replicaset:rs05:P","replicaset:rs06:S"],
        # ["replicaset:rs04:S","replicaset:rs05:S","replicaset:rs06:P"],
]

kubernetes_master_count   = 1
flavour_for_masters       = "c5.xlarge"
private_ips_for_masters   = ["172.31.29.76","172.31.29.77","172.31.29.78"]

kubernetes_worker_count   = 1
flavour_for_workers       = "c5.xlarge"
private_ips_for_workers   = ["172.31.29.79","172.31.29.80","172.31.29.81","172.31.29.82"]

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
                    device_name: '/dev/sda1',
                    ebs: {
                      volume_size: 20,
                      delete_on_termination: true,
                      volume_type: 'gp2' }
                },{
                    device_name: '/dev/xvdf',
                    ebs: {
                      volume_size: 15000,
                      delete_on_termination: true,
                      volume_type: 'gp2' }
                },
              ]
            }
        )
        if step > 1
            role 'cumulocity-base'
            role 'cumulocity-mongo'
            role 'cumulocity-mongo-configsvr' if i <= 3
            role 'cumulocity-opsmanager-agent'
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
                    device_name: '/dev/sda1',
                    ebs: {
                      volume_size: 50,
                      delete_on_termination: true,
                      volume_type: 'gp2' }
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
                role 'cumulocity-opsmanager-agent' if step > 1
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
                    device_name: '/dev/sda1',
                    ebs: {
                      volume_size: 16,
                      delete_on_termination: true,
                      volume_type: 'gp2' }
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
                instance_type: "#{flavour_for_ssagent}"
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
                    device_name: '/dev/sda1',
                    ebs: {
                      volume_size: 20,
                      delete_on_termination: true,
                      volume_type: 'gp2' }
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
                      volume_size: 20,
                      delete_on_termination: true,
                      volume_type: 'gp2' }
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

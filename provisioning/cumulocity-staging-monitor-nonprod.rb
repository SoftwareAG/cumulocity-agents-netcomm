require 'chef/provisioning/aws_driver'
with_driver 'aws:default:eu-central-1'

environment  = 'cumulocity-staging-monitor-nonprod'

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
      image_id: 'ami-8632626d', # Frankfurt
      subnet_id: 'subnet-caeb6da3',
      security_group_ids: ['sg-02ed752df3d92fa8f']
    }
  )


### CONFIGURE YOUR CLUSTER BELOW ###

c8ycore_count = 2
flavour_for_c8ycore       = "c4.xlarge"
private_ips_for_c8ycore   = ["172.31.15.211","172.31.15.212"]

ontoplb_count = 1
flavour_for_ontoplb       = "m3.medium"
private_ips_for_ontoplb   = ["172.31.15.247","172.31.15.248","172.31.15.249"]

ssagent_count = 1
flavour_for_ssagent       = "m3.medium"
private_ips_for_ssagent   = ["172.31.15.245"]
ssagent_tags  = [
        ["sms-gateway-server"]
]

mongodb_count = 3
flavour_for_mongodb       = "m4.xlarge"
private_ips_for_mongodb   = ["172.31.15.111","172.31.15.112","172.31.15.113"]
mongodb_cluster = [
        ["configreplset:config9:P","replicaset:rs01:P","replicaset:rs02:S","replicaset:rs03:A"],
        ["configreplset:config9:S","replicaset:rs01:A","replicaset:rs02:P","replicaset:rs03:S"],
        ["configreplset:config9:S","replicaset:rs01:S","replicaset:rs02:A","replicaset:rs03:P"]
]

kubernetes_master_count   = 3
private_ips_for_masters   = ["172.31.15.57","172.31.15.58","172.31.15.59"]
flavour_for_masters       = "m4.large"

kubernetes_worker_count   = 1
private_ips_for_workers   = ["172.31.15.61"]
flavour_for_workers       = "m4.xlarge"


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
                instance_type: "#{flavour_for_mongodb}"
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
                instance_type: "#{flavour_for_c8ycore}"
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
                instance_type: "#{flavour_for_ontoplb}"
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
                instance_type: "#{flavour_for_masters}"
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
                instance_type: "#{flavour_for_workers}"
            }
        )
        if step > 1
            role 'cumulocity-kubernetes' if step >= 3
            role 'cumulocity-base'
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

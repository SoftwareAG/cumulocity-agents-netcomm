require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment  = 'cumulocity-development-multikube-nonprod'

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
      # image_id: 'ami-60206719', #Ireland
      image_id: 'ami-0597ae12f89cbc55c', #Frankfurt
      # image_id: 'ami-337be65c', #Frankfurt
      subnet_id: 'subnet-c477d0bf',
      security_group_ids: ['sg-02ed752df3d92fa8f']
    }
  )

### CONFIGURE YOUR CLUSTER BELOW ###

kubernetes_master_count   = 3
flavour_for_masters       = "m4.large"
volume_size_for_masters   = 16
private_ips_for_masters   = ["172.31.19.55","172.31.19.56","172.31.19.57"]

kubernetes_worker_count   = 3
flavour_for_workers       = "c4.large"
volume_size_for_workers   = 30
private_ips_for_workers   = ["172.31.19.61","172.31.19.62","172.31.19.63","172.31.19.64","172.31.19.65"]


### END OF CLUSTER CONFIGURATION ###

defaultStep = ENV['STEP'].to_i || 1

initStep = Integer(::File.read("/tmp/.ps-#{environment}.steps").chomp) rescue defaultStep

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

        1.upto(kubernetes_master_count) do |i|
            machine "#{environment}_master_#{i}" do
                add_machine_options(
                    bootstrap_options: {
                        # private_ip_address: "#{private_ips_for_masters[i-1]}",
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
                    # role 'cumulocity-chaos-monkey' if step == 7
                    recipe 'cumulocity-kubernetes::certs_upload' if step == 5 && i == 1
                end
            end
        end

        1.upto(kubernetes_worker_count) do |i|
            machine "#{environment}_worker_#{i}" do
            add_machine_options(
                bootstrap_options: {
                    # private_ip_address: "#{private_ips_for_workers[i-1]}",
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
                # role 'cumulocity-chaos-monkey' if step == 7
            end
            end
        end
    end
    else
        machine_batch do
            1.upto(kubernetes_master_count) do |i|
                machine "#{environment}_master_#{i}"
            end

            1.upto(kubernetes_worker_count) do |i|
                machine "#{environment}_worker_#{i}"
            end

            action :destroy
        end
    end

end

file "/tmp/.ps-#{environment}.steps" do
    action :delete
end

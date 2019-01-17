# frozen_string_literal: true

require 'chef/provisioning/aws_driver'
with_driver 'aws:cumulocity:eu-central-1'

environment = 'opsmanager-nonprod'

with_chef_environment environment
with_chef_server(
  'https://chef12.cumulocity.com/organizations/cumulocity-devel',
  client_name: Chef::Config[:node_name],
  signing_key_filename: Chef::Config[:client_key]
)

with_machine_options(
  convergence_options: {
    ssl_verify_mode: 'verify_none',
    chef_version: '12.21.31'
  },
  ssh_username: 'centos'
)

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

opsmanagers_count = 3
flavours_for_opsmanagers = ['c5.2xlarge', 'c5.4xlarge', 'c5.2xlarge']
private_ips_for_opsmanagers = ['172.31.28.30', '172.31.28.31', '172.31.28.32']
ebses_for_opsmanagers = [2000, 16384, 16384]
opsmanager_mongodb_cluster = [
  ['replicaset:rs09:P'],
  ['replicaset:rs09:S'],
  ['replicaset:rs09:S']
]

### END OF CLUSTER CONFIGURATION ###

initStep = begin
  Integer(::File.read("/tmp/.ps-#{environment}.steps").chomp)
           rescue StandardError
             1
end
(initStep..3).each do |step|
  if step >= 1

    current_step = -> { step }
    file "/tmp/.ps-#{environment}.steps" do
      content current_step.call.to_s
    end

    ruby_block 'next-step-is' do
      block do
        current_step = ::File.read("/tmp/.ps-#{environment}.steps").chomp
        puts ''
        puts '===================================='
        puts "T h e  c u r r e n t  s t e p  is  #{current_step}"
        puts '===================================='
        puts ''
        sleep 4
        only_if { ::File.exist?("/tmp/.ps-#{environment}.steps") }
      end
    end

    machine_batch do
      1.upto(opsmanagers_count) do |i|
        machine "#{environment}_node_#{i}" do
          add_machine_options(
            bootstrap_options: {
              private_ip_address: (private_ips_for_opsmanagers[i - 1]).to_s,
              instance_type: (flavours_for_opsmanagers[i - 1]).to_s,
              block_device_mappings: [{
                device_name: '/dev/xvdf',
                ebs: {
                  volume_size: 20
                }
              },
              {
                device_name: '/dev/xvdg',
                ebs: {
                  volume_size: ebses_for_opsmanagers[i - 1],
                  volume_type: 'gp2'
                }
              }]
            }
          )
          opsmanager_mongodb_cluster[i - 1].each do |m_tag|
            tag m_tag
          end

          if step == 1
            role 'cumulocity-base'
            role 'cumulocity-opsmanager-backing'
          end

          if step == 2
            role 'cumulocity-opsmanager-agent'
            role 'cumulocity-opsmanager-server'
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

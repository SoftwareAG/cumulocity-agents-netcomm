# frozen_string_literal: true

require 'chef/provisioning/ssh_driver'

with_driver 'ssh'

environment = 'opsmanager-nordex-prod'

with_chef_environment environment
# with_chef_server(
#   'https://chef12.cumulocity.com/organizations/cumulocity-devel',
#   client_name: Chef::Config[:node_name],
#   signing_key_filename: Chef::Config[:client_key]
# )

with_machine_options({
  convergence_options: {
    ssl_verify_mode: 'verify_none',
    chef_version: "12.21.31"
  },
  ssh_username: "centos"
})

opsmanagers_count = 3
external_ips_for_opsmanagers = ['10.90.162.71', '10.90.162.72', '10.90.162.73']
# internal_ips_for_opsmanagers = ['172.31.10.161', '172.31.10.163', '172.31.10.182']
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

for step in initStep..3

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
          converge true
          add_machine_options(
            transport_options: {
              'ip_address' => external_ips_for_opsmanagers[i - 1].to_s,
              'username' => 'pbrzozowski',
              'ssh_options' => {
                'password' => 'centos',
                'keys' => ['/home/core/.ssh/id_rsa_elite'],
              }
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

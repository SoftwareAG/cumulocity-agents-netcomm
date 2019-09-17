name 'cumulocity-base'
description 'Base role applied to all nodes'

override_attributes(
  'authorization' => {
    'sudo'  => {
      'groups' => ['wheel']
    }
  }
)

run_list(
                    # 'recipe[swap::swapfile]',
                    # 'recipe[cumulocity-os-update]',
  'recipe[chef-client::service]',
  'recipe[cumulocity]',
  'recipe[cumulocity-rsyslog]',
  'recipe[ulimit]',
  'recipe[chef-client::delete_validation]',
  'recipe[runit]',
  # 'recipe[chef-client]',
  # 'recipe[el-sysctl]',
  # 'recipe[security-scripts::tmout]',
  # 'recipe[yum::config]',
  # 'recipe[chef-client::delete_validation]',
  # 'recipe[chef-client::config]',
  # 'recipe[chef-client::service]',
                    # 'recipe[chef-client::logrotate]',
                    # 'recipe[pam::login]',
                    # 'recipe[yum::epel]',
  # 'recipe[cumulocity-repository]',
  # 'recipe[motd-tail]',
                    # 'recipe[nagios::client]',
                    # 'recipe[nagios::knife_client]',
  # 'recipe[tools]',
  'recipe[openssh]',
  'recipe[ntp]'
)

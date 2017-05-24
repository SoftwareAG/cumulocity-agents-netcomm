name 'cumulocity-base'
description 'Base role applied to all nodes'

run_list(
                    # 'recipe[swap::swapfile]',
  'recipe[ulimit]',
  # 'recipe[el-sysctl]',
  # 'recipe[security-scripts::tmout]',
  # 'recipe[yum::config]',
  # 'recipe[chef-client::delete_validation]',
  # 'recipe[chef-client::config]',
  # 'recipe[chef-client::service]',
                    # 'recipe[chef-client::logrotate]',
  # 'recipe[users::admin]',
  # 'recipe[sudo]',
                    # 'recipe[pam::login]',
                    # 'recipe[yum::epel]',
  # 'recipe[cumulocity-repository]',
  # 'recipe[motd-tail]',
                    # 'recipe[nagios::client]',
                    # 'recipe[nagios::knife_client]',
  # 'recipe[tools]',
  'recipe[openssh]'
  # 'recipe[ntp]'
)

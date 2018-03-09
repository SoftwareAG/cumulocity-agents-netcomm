name "cumulocity-production-singlenode-with-vendme"
description "production-singlenode-with-vendme"


default_attributes(
    'vendme-platform-agent' => {
      'install-agent' => nil,
      'install-platform' => true,
      'install-tracker' => nil
  }
)

override_attributes(
    'vendme-platform-agent' => {
        'platform-tenant-branch' => 'vendme-frankfurt'
    }
)

run_list(
 "recipe[vendme-agent-platform]"
)

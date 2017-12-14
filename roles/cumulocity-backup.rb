require  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'chef_config'))

name "cumulocity-backup"
description "Install and configure AWS backup script"

default_attributes(
    'backup_script' => {
      'AWS_SECRET_ACCESS_KEY' => "sdHdz6jThxLvFFkMKvXJCl2yQf3uNX5TUqmztaVD",
      'AWS_ACCESS_KEY_ID' => "AKIAJ62CYMWV47PFPD6A"
  }
)

override_attributes(
    'backup_script' => {
      'snapshots' => true,
      'AMIs' => true
  }
)

run_list(
    "recipe[cumulocity-backup-script]"
)

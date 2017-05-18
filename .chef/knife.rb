current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "ffaerber"
client_key               "#{current_dir}/ffaerber.pem"
validation_client_name   "myorg-validator"
validation_key           "#{current_dir}/myorg-validator.pem"
chef_server_url          "https://ec2-52-16-90-217.eu-west-1.compute.amazonaws.com/organizations/myorg"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]


# AWS
# chmod 600 .chef/.aws/ffaerber.pem
# ssh-add .chef/.aws/ffaerber.pem
knife[:ssh_key_name]          = 'ffaerber'
knife[:aws_access_key_id]     = "AKIAJFCZY74TCITUMZYQ"
knife[:aws_secret_access_key] = "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"
knife[:availability_zone]     = 'eu-west-1a'
knife[:region]                = 'eu-west-1'
knife[:ssh_user]              = 'centos'
knife[:image]                 = 'ami-0d063c6b' # https://wiki.centos.org/Cloud/AWS
knife[:flavor]                = 'm4.large'

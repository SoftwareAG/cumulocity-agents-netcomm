require 'yaml'
current_dir = File.dirname(__FILE__)
organizations = YAML.load_file("#{current_dir}/organizations/index.yml")

if ENV['ORGNAME']
  organization_name  = ENV['ORGNAME']
  organization       = organizations[organization_name]
  if organization
    if ENV['NO_PROMPT_ORGANIZATION'] != "true"
      puts "knife is running with organization: #{organization_name}"
    end
  else
    puts "Organization is '#{organization_name}' but it is not found in ./chef/organizations/index.yml"
    exit!
  end
else
  puts "You must specify a organization. Possible organizations: #{organizations.keys.join(', ')}"
  puts "set the organization via: export ORGNAME=name_of_the_organization"
  exit!
end

log_level                :info
log_location             STDOUT
node_name                organization['node_name']
client_key               "#{current_dir}/organizations/#{organization_name}/#{organization['client_key']}"
validation_client_name   "#{organization_name}-validator"
validation_key           "#{current_dir}/organizations/#{organization_name}/validator.pem"
chef_server_url          organization['pub']
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]


knife[:ssh_key_name]          = organization['knife']['ssh_key_name']
knife[:aws_access_key_id]     = organization['knife']['aws_access_key_id']
knife[:aws_secret_access_key] = organization['knife']['aws_secret_access_key']
knife[:flavor]                = 'm4.large'
knife[:availability_zone]     = 'eu-west-1a'
knife[:region]                = 'eu-west-1'
knife[:ssh_user]              = 'centos'
# ami-0d063c6b default centos7
# ami-ac524fca custom centos7 without SELinux
knife[:image]                 = 'ami-ac524fca'

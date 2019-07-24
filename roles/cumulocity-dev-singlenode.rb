require  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'chef_config'))

name "cumulocity-dev-singlenode"
description "Cumulocity Singlenode (Sandbox)"


override_attributes(
 "rubygems_url" => "http://rubygems.org",

  "useVaults" => false,
  "domainname" => "domain.com",
    "ulimit" => {
      "users" => {
        "mongod" => {
          "filehandle_hard_limit" => 64000,
          "process_hard_limit" => 64000
        }
      },
    "root" => {
      "nofile" => {
        "soft" => "10240",
        "hard" => "20480"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    },
    "karaf" => {
      "nofile" => {
        "soft" => "20240",
        "hard" => "30480"
      },
      "nproc" => {
        "soft" => "3072",
        "hard" => "5000"
      }
    },
    "nginx" => {
      "nofile" => {
        "soft" => "1024",
        "hard" => "8192"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    }
  }
)

run_list(
  "role[cumulocity-base]",
  "recipe[cumulocity::mongo]",
  "recipe[cumulocity::core]",
  "recipe[cumulocity::core_cep]",
  "recipe[cumulocity::karaf_cep]",
  "recipe[cumulocity::karaf_dev-x-agents]",
  "recipe[cumulocity::external-lb]",
  "recipe[cumulocity-ssagents]"
)


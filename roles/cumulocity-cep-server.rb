name "cumulocity-cep-server"
description "This is a dummy role just to indicate that the specific node is in CEP server role"

override_attributes(
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 1024,
        "filehandle_hard_limit": 8192,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      }
    }
  }
)

run_list(
  "role[cumulocity-base]",
  "recipe[cumulocity::core_cep]",
  "recipe[cumulocity::karaf_cep]",
  "recipe[cumulocity::internal-lb_mongos]"
)

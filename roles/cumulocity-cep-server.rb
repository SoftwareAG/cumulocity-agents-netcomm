name "cumulocity-cep-server"
description "This is a dummy role just to indicate that the specific node is in CEP server role"

override_attributes(
    "ulimit" => {
      "root" => {
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
  "recipe[cumulocity::core_cep]",
  "recipe[cumulocity::karaf_cep]",
  "recipe[cumulocity::internal-lb_mongos]"
)

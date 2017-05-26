name "cumulocity-internal-lb"
description "Cumulocity Internal LB"

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
 "recipe[cumulocity-internal-lb]"
)

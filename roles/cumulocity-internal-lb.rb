name "cumulocity-internal-lb"
description "Cumulocity Internal LB"

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
 "recipe[cumulocity::internal-lb]"
)

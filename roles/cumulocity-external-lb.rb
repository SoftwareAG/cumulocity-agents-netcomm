name "cumulocity-external-lb"
description "Cumulocity External LB"

override_attributes(
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      },
      "nginx": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      }
    }
  }
)

run_list(
 "role[cumulocity-base]",
 "recipe[cumulocity::external-lb]"
)

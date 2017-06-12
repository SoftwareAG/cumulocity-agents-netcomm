name "cumulocity-core"
description "Cumulocity Core Karaf"

override_attributes(
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      },
      "karaf": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 2048,
        "process_hard_limit": 4096
      },
      "nginx": {
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
 "recipe[cumulocity::core_haproxy]",
 "recipe[cumulocity::core]"
)

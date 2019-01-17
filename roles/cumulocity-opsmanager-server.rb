name "cumulocity-opsmanager-server"
description "Ops Manager server setup"

run_list(
  "recipe[cumulocity-opsmanager::server]",
)

default_attributes(
  "ulimit": {
    "users": {
      "mongodb-mms": {
        "filehandle_soft_limit": 1048576,
        "filehandle_hard_limit": 1048576,
        "process_soft_limit": 1048576,
        "process_hard_limit": 1048576
      }
    }
  }
)
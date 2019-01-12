name "cumulocity-opsmanager-agent"
description "Ops Manager agent setup"

run_list(
  "recipe[cumulocity-opsmanager::agent]",
)

default_attributes(
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 1048576,
        "filehandle_hard_limit": 1048576,
        "process_soft_limit": 1048576,
        "process_hard_limit": 1048576
      },
      "mongod": {
        "filehandle_soft_limit": 1048576,
        "filehandle_hard_limit": 1048576,
        "process_soft_limit": 1048576,
        "process_hard_limit": 1048576
      }
    }
  },
  "systemd": {
    "ulimits": {
      "DefaultLimitNOFILE": 1048576,
      "DefaultLimitNPROC": 1048576
    }
  }
)

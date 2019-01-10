name "mongodb"
description "Role for mongodb node"

override_attributes(

  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 150000,
        "filehandle_hard_limit": 160000,
        "process_soft_limit": 150000,
        "process_hard_limit": 160000
      },
      "mongod": {
        "filehandle_soft_limit": 150000,
        "filehandle_hard_limit": 160000,
        "process_soft_limit": 150000,
        "process_hard_limit": 160000
      }
    }
  },
      "systemd": {
        "ulimits": {
            "DefaultLimitNOFILE": 64000,
            "DefaultLimitNPROC": 64000,
        }
  }
)


run_list(
  "recipe[ulimit]",
  "recipe[sc-mongodb]"
)

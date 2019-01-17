# frozen_string_literal: true

name "cumulocity-mongo"
description "Mongo setup for replica sets"

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
  },
  "nagios" => {
    "checks" => {
      "memory" => {
        "warning" => 4,
        "critical" => 1
      }
    }
  }
)

run_list(
  "role[cumulocity-base]",
  "recipe[cumulocity::mongo]"
)

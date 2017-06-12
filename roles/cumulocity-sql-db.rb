name "cumulocity-sql-db"
description "Cumulocity SQL database role"

override_attributes(
  "nagios" => {
    "plugins" => {
      "check_postgres" => {
        "database" => "cumulocity",
        "username" => "c8ymonitoring",
        "password" => "fiWs.d2Ecr^4sXedsR"
      }
    }
  },
  "cumulocity-postgres" => {
    "plugins" => {
      "c8ymonitoring.password" => "fiWs.d2Ecr^4sXedsR"
    }
  },
  "ulimit": {
    "users": {
      "postgres": {
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
  "recipe[cumulocity::postgres]"
)

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
  "ulimit" => {
    "postgres" => {
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
  "recipe[cumulocity::postgres]"
)
